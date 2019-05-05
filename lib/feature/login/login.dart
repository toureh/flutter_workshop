import 'package:flutter/material.dart';
import 'package:flutter_workshop/config/l10n.dart';
import 'package:flutter_workshop/custom/custom_app_bar.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: L10n.getString(context, 'login_title'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: _form(context),
      ),
    );
  }

    Form _form(BuildContext context) {
    return Form(
        child: Column(
          children: <Widget>[
            _emailField(context),
            SizedBox(height: 40),
            _passwordField(context),
            SizedBox(height: 60),
            _button(context)
          ],
        ),
      );
  }

  TextFormField _passwordField(BuildContext context) {
    return TextFormField(
              decoration: InputDecoration(
                  labelText: L10n.getString(context, 'login_password')),
            );
  }

  TextFormField _emailField(BuildContext context) {
    return TextFormField(
              decoration: InputDecoration(
                  labelText: L10n.getString(context, 'login_email')),
            );
  }

  Widget _button(BuildContext context) {
    return ButtonTheme(
      height: 48.0,
      minWidth: double.maxFinite,
      child: FlatButton(
          child: Text(L10n.getString(context, 'login_title')),
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: () {}),
    );
  }
}