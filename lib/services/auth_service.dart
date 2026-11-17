import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class AuthService {
  final _supabase = SupabaseConfig.client;

  Future<
    String?
  >
  signUpCustomer({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user !=
          null) {
        final wiivCard = 'WIIV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

        await _supabase
            .from(
              'profiles',
            )
            .insert(
              {
                'id': user.id,
                'full_name': fullName,
                'email': email,
                'role': 'customer',
                'wiiv_card_number': wiivCard,
                'wiiv_points': 100, // Bonus points on registration
              },
            );
      }
      return null;
    } on AuthException catch (
      e
    ) {
      return e.message;
    } catch (
      e
    ) {
      return e.toString();
    }
  }

  Future<
    Map<
      String,
      dynamic
    >?
  >
  loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user !=
          null) {
        final profile = await _supabase
            .from(
              'profiles',
            )
            .select()
            .eq(
              'id',
              user.id,
            )
            .single();
        return profile;
      }
      return null;
    } catch (
      e
    ) {
      rethrow;
    }
  }

  Future<
    void
  >
  signOut() async {
    await _supabase.auth.signOut();
  }
}
