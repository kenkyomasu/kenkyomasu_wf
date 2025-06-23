import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:proyecto_web_flutter_bd/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen({super.key});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _rutController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'usuarios',
  );

  late final FirebaseAuth _auth;

  String _tipoSeleccionado = 'user';

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<bool> _esAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final snapshot = await _dbRef.child(user.email!.split('@')[0]).get();
    if (!snapshot.exists) return false;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data['tipo'] == 'admin';
  }

  Future<int> _cantidadUsuarios() async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists) return 0;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.length;
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _auth = FirebaseAuth.instance;
  }

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _claveController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final cantidadUsuarios = await _cantidadUsuarios();

        String tipoUsuario = 'user';
        if (cantidadUsuarios == 0) {
          tipoUsuario = 'admin';
        } else {
          final esAdmin = await _esAdmin();
          if (esAdmin) {
            tipoUsuario = _tipoSeleccionado;
          }
        }

        // Guardar otros datos en Realtime Database
        await _dbRef.child(_rutController.text).set({
          'rut': _rutController.text,
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'correo': _correoController.text,
          'telefono': _telefonoController.text,
          'clave': _hashPassword(_claveController.text),
          'tipo': tipoUsuario,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado correctamente')),
        );
        _formKey.currentState!.reset();
        setState(() {
          _tipoSeleccionado = 'user';
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear usuario: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _rutController,
                decoration: const InputDecoration(
                  labelText: 'RUT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu RUT';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu apellido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _claveController,
                decoration: const InputDecoration(
                  labelText: 'Clave',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una clave';
                  }
                  if (value.length < 6) {
                    return 'La clave debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu número de teléfono';
                  }
                  if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FutureBuilder<bool>(
                future: _esAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.hasData && snapshot.data == true) {
                    return FutureBuilder<int>(
                      future: _cantidadUsuarios(),
                      builder: (context, snapshotCount) {
                        if (snapshotCount.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        if (snapshotCount.hasData && snapshotCount.data! > 0) {
                          return DropdownButtonFormField<String>(
                            value: _tipoSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de usuario',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Administrador'),
                              ),
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('Usuario'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _tipoSeleccionado = value ?? 'user';
                              });
                            },
                          );
                        }
                        return const SizedBox();
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
