class Validators {
  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email obrigatório';
    if (!s.contains('@') || !s.contains('.')) return 'Email inválido';
    return null;
  }

  static String? password(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Password obrigatória';
    if (s.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? nonEmpty(String? v, String label) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return '$label obrigatório';
    return null;
  }
}
