import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/presentation/blocs/sign_up_bloc.dart';
import 'package:mobile/features/auth/presentation/pages/signup_pages.dart';
import 'package:mobile/features/flight_info/presentation/blocs/flight_bloc.dart';
// import 'package:mobile/features/flight_info/presentation/pages/translator_page.dart';
import 'package:mobile/features/chat/presentation/pages/translator_page.dart';
import 'package:mobile/features/flight_info/presentation/pages/flight_empty_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/form/presentation/blocs/form_bloc.dart';
import 'package:mobile/features/form/presentation/pages/translator_page.dart';
import 'package:mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';

import 'features/auth/presentation/blocs/login_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/flight_info/presentation/pages/flight_detail_page.dart';
import 'features/flight_info/presentation/pages/flight_page.dart';

import 'features/onboarding/presentation/pages/onboarding_page.dart';

import 'injection_container.dart' as di;
import 'features/flight_info/domain/entities/flight.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => di.sl<LoginCubit>(),
        ),
        BlocProvider<SignUpBloc>(
          create: (_) => di.sl<SignUpBloc>(),
        ),
        BlocProvider<OnboardingBloc>(
          create: (_) => di.sl<OnboardingBloc>(),
        ),
        BlocProvider<FormBloc>(
          create: (_) => di.sl<FormBloc>(),
        ),
        BlocProvider<FlightBloc>(
          create: (_) => di.sl<FlightBloc>(),
        )
      ],
      child: MaterialApp(
        title: 'PassMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          primaryTextTheme:
              GoogleFonts.interTextTheme(ThemeData.dark().primaryTextTheme),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2196F3),
          ),
        ),
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (_) => const OnboardingPage(),
          '/login': (_) => LoginPage(),
          '/signup': (_) => SignUpPage(),
          // '/flights/empty': (_) => const FlightEmptyPage(),
          '/flights': (_) => FlightPage(),
          '/flights/detail': (context) => FlightDetailPage(
              flight: ModalRoute.of(context)!.settings.arguments as Flight),
          '/profile': (_) => const ProfilePage(),
          '/form': (_) => TranslatorFormPage(),
          '/flights/chat': (_) => TranslatorPage(),
        },
      ),
    );
  }
}
