import 'dart:io';

void main() async {
  print('\n=== Agente Interactivo para enviar a GitHub ===');

  // 1. Preguntar por el link del nuevo repositorio
  stdout.write('Introduce el enlace del repositorio de GitHub (ej. https://github.com/usuario/repo.git): ');
  final repoLink = stdin.readLineSync();
  if (repoLink == null || repoLink.trim().isEmpty) {
    print('Error: El enlace del repositorio es obligatorio.');
    return;
  }

  // 2. Preguntar por el mensaje del commit
  stdout.write('Introduce el mensaje para el commit (Enter para "Primer commit"): ');
  String? commitMessage = stdin.readLineSync();
  if (commitMessage == null || commitMessage.trim().isEmpty) {
    commitMessage = 'Primer commit';
  }

  // 3. Establecer la rama main por default o pedir nombre
  stdout.write('Introduce el nombre de la rama (Enter para "main"): ');
  String? branchName = stdin.readLineSync();
  if (branchName == null || branchName.trim().isEmpty) {
    branchName = 'main';
  }

  print('\n=> Iniciando el proceso de Git...\n');

  // Comprobar si git ya está inicializado
  final gitStatus = await Process.run('git', ['status']);
  if (gitStatus.exitCode != 0) {
    print('-> Inicializando repositorio Git (git init)');
    await ejecutarComando('git', ['init']);
  } else {
    print('-> El repositorio Git ya estaba inicializado.');
  }

  print('-> Añadiendo archivos (git add .)');
  await ejecutarComando('git', ['add', '.']);

  print('-> Creando commit (git commit -m "\$commitMessage")');
  await ejecutarComando('git', ['commit', '-m', commitMessage]);

  print('-> Configurando la rama a "\$branchName" (git branch -M \$branchName)');
  await ejecutarComando('git', ['branch', '-M', branchName]);

  // Quitamos cualquier origen remoto que pueda existir por si acaso se equivocó o ya tenía uno
  await Process.run('git', ['remote', 'remove', 'origin']);

  print('-> Vinculando con el repositorio remoto (git remote add origin ...)');
  await ejecutarComando('git', ['remote', 'add', 'origin', repoLink.trim()]);

  print('-> Subiendo los cambios a GitHub (git push -u origin \$branchName)');
  final pushCode = await ejecutarComando('git', ['push', '-u', 'origin', branchName]);

  if (pushCode == 0) {
    print('\n¡PROCESO COMPLETADO CON ÉXITO! 🎉');
    print('El código está ahora en: \$repoLink');
  } else {
    print('\n❌ Ocurrió un error al intentar hacer push a GitHub.');
    print('Por favor, verifica el enlace, tus credenciales de Git y tu conexión a internet.');
  }
}

Future<int> ejecutarComando(String ejecutable, List<String> argumentos) async {
  try {
    final proceso = await Process.start(
      ejecutable,
      argumentos,
      mode: ProcessStartMode.inheritStdio, 
    );
    return await proceso.exitCode;
  } catch (e) {
    print('Error al ejecutar el comando \$ejecutable: \$e');
    return -1;
  }
}
