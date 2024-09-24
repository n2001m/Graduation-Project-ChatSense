import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import '../pages/widgets/preview_dialog.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? audioUrl;
  final String? emotion;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      this.audioUrl,
      this.emotion});

  @override
  Widget build(BuildContext context) {
    //light vs. dark mode for correct bubble colors
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if (audioUrl != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ElevatedButton.icon(
            icon: const Icon(
              Icons.play_circle,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (c) {
                    return PreviewDialogWidget(
                      audioPath: audioUrl!,
                      recieverEmail: "",
                      recieverID: "",
                      previewType: PreviewType.viewOnly,
                    );
                  });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentUser ? Colors.green : Colors.grey),
            label: Text(
              "Voice Note${emotion != null ? '\n$emotion' : ''}",
              style: TextStyle(color: const Color.fromARGB(255, 68, 68, 68)),
            )),
      );
    }
    return GestureDetector(
      onTap: audioUrl != null
          ? () {
              showDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (c) {
                    return PreviewDialogWidget(
                      audioPath: audioUrl!,
                      recieverEmail: "",
                      recieverID: "",
                      previewType: PreviewType.viewOnly,
                    );
                  });
            }
          : null,
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: BoxDecoration(
            color: isCurrentUser
                ? (isDarkMode ? Colors.green.shade500 : Colors.green.shade500)
                : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: audioUrl != null
            ? Text(
                "View Voice Message",
                style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black)),
              )
            : Text(
                message,
                style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black)),
              ),
      ),
    );
  }
}
