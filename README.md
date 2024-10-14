# Speech Emotion Recognition in Voice Messages

## Project Overview

This project implements a Speech Emotion Recognition (SER) system integrated into a Flutter chat application. The system analyzes voice messages to detect emotions, enhancing communication by providing users with emotional context.

## Repository Structure

The repository contains two main folders:

1. `fullApp/`: Contains the Flutter application code.
2. `Model/`: Contains the SER model, pipeline, and related files.


## SER Model (`Model/`)

The `Model/` folder contains all the necessary components for the Speech Emotion Recognition system.

### Contents

- SER model file
- Pipeline script for processing audio and making predictions
- Preprocessing, training, and testing scripts


## Flutter Application (`fullApp/`)

The Flutter application provides a user interface for sending and receiving voice messages with emotion recognition capabilities.

### Features

- User authentication
- Real-time chat functionality
- Voice message recording and playback
- Integration with SER model for emotion analysis
- Emotion preview before sending messages

### Setup and Running

1. Ensure you have Flutter installed on your system.
2. Navigate to the `fullApp/` directory.
3. Run `flutter pub get` to install dependencies.
4. Connect a device or start an emulator.
5. Run `flutter run` to start the application.
