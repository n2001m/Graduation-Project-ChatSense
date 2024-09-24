from flask import Flask, request, jsonify
import librosa
import numpy as np
import joblib
import pandas as pd
import warnings
warnings.filterwarnings("ignore")
app = Flask(__name__)
# Load SVM model and scaler
loaded_svm_model = joblib.load("svm_model_3sec_allF.pkl")
loaded_scaler = joblib.load("scaler_3sec_allF.pkl")

# Function to preprocess audio
def preprocess_audio(audio_path, target_sr=16000):
    # Load audio file
    data, original_sr = librosa.load(audio_path, sr=target_sr)
    
    # Trim silence
    trimmed_data, _ = librosa.effects.trim(data)
    
    # Apply noise reduction using spectral subtraction
    stft = librosa.stft(trimmed_data)
    noise_estimation = np.mean(np.abs(stft), axis=1)
    clean_stft = np.maximum(np.abs(stft) - 2 * noise_estimation[:, np.newaxis], 0.0)
    clean_data = librosa.istft(clean_stft)
    
    return clean_data
# Function to segment audio with overlap
def segment_audio(audio, segment_size=3, overlap=0.5):
    segment_size_samples = int(segment_size * 16000)  # Convert segment size to samples
    hop_length = int(segment_size_samples * (1 - overlap))  # Calculate hop length
    if len(audio) <= segment_size_samples:
        segments = [audio]
    else:
        segments = []
        for i in range(0, len(audio) - segment_size_samples + 1, hop_length):
            segment = audio[i:i + segment_size_samples]
            segments.append(segment)
    return segments

# Function to extract features
def extract_features(audio):
    sampling_rate=16000
    mfcc = librosa.feature.mfcc(y=audio, sr=sampling_rate)
    mfcc_mean = np.mean(mfcc, axis=1)
    speech_rate = librosa.feature.spectral_centroid(y=audio, sr=sampling_rate)
    speech_rate_mean = np.mean(speech_rate)
    energy = librosa.feature.rms(y=audio)
    energy_mean = np.mean(energy)
    pitch = librosa.yin(y=audio, fmin=8, fmax=600)
    pitch_mean = np.mean(pitch)
    zcr = librosa.feature.zero_crossing_rate(audio)
    zcr_mean = np.mean(zcr)
    mel_spec = librosa.feature.melspectrogram(y=audio, sr=sampling_rate)
    kurtosis = librosa.feature.mfcc(S=librosa.power_to_db(mel_spec))
    kurtosis_mean = np.mean(kurtosis)
    return np.concatenate([mfcc_mean, [speech_rate_mean, energy_mean, pitch_mean, zcr_mean, kurtosis_mean]])

# Function to load the SVM model and the StandardScaler objects
def load_model_and_scaler(model_filename, scaler_filename):
    loaded_svm_model = joblib.load(model_filename)
    loaded_scaler = joblib.load(scaler_filename)
    return loaded_svm_model, loaded_scaler

# Function to predict emotion label for each segment
def predict_emotion_segments(segments, loaded_svm_model, loaded_scaler):
    predicted_labels = []
    for segment in segments:
        segment_features = extract_features(segment)
        standardized_features = loaded_scaler.transform(segment_features.reshape(1, -1))
        predicted_label = loaded_svm_model.predict(standardized_features)
        predicted_labels.append(predicted_label)
    return predicted_labels


@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'audio_file' not in request.files:
            return jsonify({'error': 'No audio file provided'}), 400
        
        audio_file = request.files['audio_file']
        if audio_file.filename == '':
            return jsonify({'error': 'No audio file selected'}), 400
        
        # Save the uploaded file to a temporary location
        audio_path = 'temp_audio.wav'
        audio_file.save(audio_path)
    
        preprocessed_audio = preprocess_audio("temp_audio.wav")

        # Check if the audio duration is less than 3 seconds
        if len(preprocessed_audio) / 16000 < 3:
            # If less than 3 seconds, directly extract features and predict label
            audio_features = extract_features(preprocessed_audio)
            standardized_features = loaded_scaler.transform(audio_features.reshape(1, -1))
            predicted_label = loaded_svm_model.predict(standardized_features)
            print(predicted_labels)
            return jsonify({'predicted_label': predicted_label.tolist()})
                
        else:
            # If greater than or equal to 3 seconds, segment the audio
            segments = segment_audio(preprocessed_audio)
            print("Segmented audio into", len(segments), "segments")

            # Predict emotion label for each segment
            predicted_labels = predict_emotion_segments(segments, loaded_svm_model, loaded_scaler)
            predicted_labels = [label[0] for label in predicted_labels]
            print(predicted_labels)
            return jsonify({'predicted_labels': predicted_labels})
    except Exception as e:
        # Return an error response if something goes wrong
        return jsonify({"error": str(e)}), 500        

if __name__ == '__main__':
    app.run(host='0.0.0.0')