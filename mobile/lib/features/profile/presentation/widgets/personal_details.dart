import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/presentation/pages/update_profile_page.dart';
import 'package:mobile/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/service/local_storage_service.dart';
import 'package:mobile/injection_container.dart';

class PersonalDetails extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String email;

  const PersonalDetails(
      {super.key,
      required this.imageUrl,
      required this.name,
      required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage(imageUrl),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
            Text(email,
                style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280)))
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider<ProfileBloc>(
                  create: (context) => sl<ProfileBloc>(),
                  child: const UpdateProfilePage(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
