import 'dart:io';

void main() async {
  print('=============================================');
  print('    Agente para enviar repositorio a GitHub  ');
  print('=============================================');

  // 1. Pedir el link del repositorio
  stdout.write('1. Ingresa el link del repositorio de GitHub: ');
  String? repoUrl = stdin.readLineSync()?.trim();
  if (repoUrl == null || repoUrl.isEmpty) {
    print('Error: El link del repositorio no puede estar vacío.');
    return;
  }

  // 2. Pedir el mensaje del commit
  stdout.write('2. Ingresa el mensaje del commit (Ej. "Primer commit"): ');
  String? commitMessage = stdin.readLineSync()?.trim();
  if (commitMessage == null || commitMessage.isEmpty) {
    commitMessage = 'Primer commit'; // Mensaje por defecto si se deja vacío
    print('Mensaje vacío, usando por defecto: "$commitMessage"');
  }

  // 3. Pedir el nombre de la rama (por defecto 'main')
  stdout.write('3. Ingresa el nombre de la rama (Presiona Enter para usar "main"): ');
  String? branchName = stdin.readLineSync()?.trim();
  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
  }

  print('\n---------------------------------------------');
  print('Resumen de la acción:');
  print('- Repositorio: $repoUrl');
  print('- Commit: "$commitMessage"');
  print('- Rama: $branchName');
  print('---------------------------------------------\n');

  stdout.write('¿Deseas continuar y subir los cambios? (s/n): ');
  String? confirm = stdin.readLineSync()?.trim().toLowerCase();
  if (confirm != 's' && confirm != 'y' && confirm != 'si' && confirm != 'sí') {
    print('Operación cancelada por el usuario.');
    return;
  }

  print('\nEjecutando comandos de Git...');

  // Inicializar repositorio si no está inicializado
  await runCommand('git', ['init'], 'Inicializando repositorio...');

  // Agregar todos los archivos
  await runCommand('git', ['add', '.'], 'Agregando archivos al área de preparación...');

  // Hacer el commit
  await runCommand('git', ['commit', '-m', commitMessage], 'Creando commit...', ignoreError: true); // Ignore error in case there are no new changes to commit

  // Cambiar/establecer la rama
  await runCommand('git', ['branch', '-M', branchName], 'Configurando la rama principal...');

  // Manejar el remote origin
  // Intentamos remover por si ya existe uno (ignoramos error si no existe)
  await runCommand('git', ['remote', 'remove', 'origin'], '', ignoreError: true);
  
  // Agregamos el nuevo origin
  await runCommand('git', ['remote', 'add', 'origin', repoUrl], 'Conectando con el repositorio remoto...');

  // Push al repositorio
  print('\nSubiendo archivos a GitHub (esto puede tardar unos momentos)...');
  bool pushSuccess = await runCommand('git', ['push', '-u', 'origin', branchName], '');

  if (pushSuccess) {
    print('\n✅ ¡Repositorio enviado a GitHub exitosamente!');
  } else {
    print('\n❌ Hubo un error al enviar el repositorio a GitHub. Revisa la salida de error arriba.');
  }
}

Future<bool> runCommand(String executable, List<String> arguments, String startMessage, {bool ignoreError = false}) async {
  if (startMessage.isNotEmpty) {
    print(startMessage);
  }
  try {
    var result = await Process.run(executable, arguments, runInShell: true);
    if (result.exitCode != 0) {
      if (!ignoreError) {
        print('Error ejecutando: $executable ${arguments.join(' ')}');
        print(result.stderr);
      }
      return false;
    }
    return true;
  } catch (e) {
    if (!ignoreError) {
      print('Excepción ejecutando $executable: $e');
    }
    return false;
  }
}
