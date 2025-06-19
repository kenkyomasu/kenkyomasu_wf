import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({Key? key}) : super(key: key);

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'usuarios',
  );
  final TextEditingController _rutBuscarController = TextEditingController();

  Map<String, dynamic>? _datosSeleccionados;
  List<Map<String, dynamic>> _listaUsuarios = [];

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarListaUsuarios();
  }

  @override
  void dispose() {
    _rutBuscarController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _claveController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _cargarListaUsuarios() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<Map<String, dynamic>> usuarios = [];
        data.forEach((key, value) {
          final usuario = Map<String, dynamic>.from(value);
          usuarios.add(usuario);
        });
        setState(() {
          _listaUsuarios = usuarios;
        });
      }
    });
  }

  void _buscarPorRut() async {
    final rut = _rutBuscarController.text.trim();
    if (rut.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un RUT para buscar')),
      );
      return;
    }
    final snapshot = await _dbRef.child(rut).get();
    if (snapshot.exists) {
      final datos = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _datosSeleccionados = datos;
        _nombreController.text = datos['nombre'] ?? '';
        _apellidoController.text = datos['apellido'] ?? '';
        _correoController.text = datos['correo'] ?? '';
        _claveController.text = datos['clave'] ?? '';
        _telefonoController.text = datos['telefono'] ?? '';
      });
    } else {
      setState(() {
        _datosSeleccionados = null;
        _nombreController.clear();
        _apellidoController.clear();
        _correoController.clear();
        _claveController.clear();
        _telefonoController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró usuario con ese RUT')),
      );
    }
  }

  Future<void> _editarUsuario() async {
    if (_datosSeleccionados == null) return;
    final rut = _datosSeleccionados!['rut'];
    try {
      await _dbRef.child(rut).update({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'correo': _correoController.text,
        'clave': _claveController.text,
        'telefono': _telefonoController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario actualizado correctamente')),
      );
      _buscarPorRut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar usuario: $e')),
      );
    }
  }

  Future<void> _borrarUsuario() async {
    if (_datosSeleccionados == null) return;
    final rut = _datosSeleccionados!['rut'];
    try {
      await _dbRef.child(rut).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario borrado correctamente')),
      );
      setState(() {
        _datosSeleccionados = null;
        _nombreController.clear();
        _apellidoController.clear();
        _correoController.clear();
        _claveController.clear();
        _telefonoController.clear();
      });
      _cargarListaUsuarios();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al borrar usuario: $e')));
    }
  }

  Widget _detalleUsuario() {
    if (_datosSeleccionados == null) {
      return const Text('No hay datos seleccionados');
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _correoController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _claveController,
              decoration: const InputDecoration(
                labelText: 'Clave',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _editarUsuario,
                  child: const Text('Editar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _borrarUsuario,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Borrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _rutBuscarController,
              decoration: const InputDecoration(
                labelText: 'Buscar por RUT',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _buscarPorRut,
              child: const Text('Buscar'),
            ),
            _detalleUsuario(),
            const Divider(),
            const Text('Lista de Usuarios'),
            Expanded(
              child: ListView.builder(
                itemCount: _listaUsuarios.length,
                itemBuilder: (context, index) {
                  final usuario = _listaUsuarios[index];
                  return ListTile(
                    title: Text(
                      '${usuario['nombre'] ?? ''} ${usuario['apellido'] ?? ''}',
                    ),
                    onTap: () {
                      setState(() {
                        _datosSeleccionados = usuario;
                        _nombreController.text = usuario['nombre'] ?? '';
                        _apellidoController.text = usuario['apellido'] ?? '';
                        _correoController.text = usuario['correo'] ?? '';
                        _claveController.text = usuario['clave'] ?? '';
                        _telefonoController.text = usuario['telefono'] ?? '';
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
