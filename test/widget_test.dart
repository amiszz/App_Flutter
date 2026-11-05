import 'package:app_flutter/screens/login_page.dart';
import 'package:app_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Exibe os campos de login', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Bem-vindo!'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Esqueceu sua senha?'), findsOneWidget);
  });

  testWidgets('Navega do login para cadastro', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.ensureVisible(find.text('Não possui conta? Cadastre-se'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Não possui conta? Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.text('Faça seu cadastro'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('Confirmar senha'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  testWidgets('Valida campos vazios antes de fazer login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.ensureVisible(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  test('Valida formato de e-mail', () {
    expect(validarEmail(''), 'Informe seu e-mail.');
    expect(validarEmail('sem-arroba'), 'Digite um e-mail válido.');
    expect(validarEmail('usuario@example.com'), isNull);
  });
}
