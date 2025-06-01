import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/models/contact_model.dart';
import 'package:whatsapp/screens/screens.dart';
import 'package:whatsapp/utils/utils.dart';
import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final ContactModel contact;
  const ContactTile({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, ChatScreen.id, arguments: contact);
        },
        splashColor: AppColors.lightGreen.withOpacity(0.1),
        highlightColor: AppColors.lightGreen.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.lightGreen.withOpacity(0.1),
                width: 0.5,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: contact.profilePicture ?? '',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.lightGrey,
                      child: Image.asset(
                        'assets/images/profileOne.png',
                        width: 80,
                        height: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.message,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.lightGrey,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    contact.time,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (contact.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.brightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${contact.unreadCount}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
