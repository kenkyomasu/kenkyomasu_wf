#!/bin/bash

# Script para desplegar Flutter web en GitHub Pages

# Variables
REPO_URL="https://github.com/tu_usuario/kenkyomasu_wf.git"
BRANCH="gh-pages"
BUILD_DIR="build/web"
TMP_DIR="gh-pages-temp"

# Paso 1: Construir la app Flutter web (opcional, si ya está compilada puedes comentar esta línea)
flutter build web

# Paso 2: Clonar el repositorio en un directorio temporal
rm -rf $TMP_DIR
git clone $REPO_URL $TMP_DIR

# Paso 3: Cambiar a la rama gh-pages o crearla si no existe
cd $TMP_DIR
if git show-ref --quiet refs/heads/$BRANCH; then
  git checkout $BRANCH
else
  git checkout --orphan $BRANCH
fi

# Paso 4: Borrar todo el contenido actual
git rm -rf .

# Paso 5: Copiar los archivos compilados a la raíz del repositorio temporal
cp -r ../$BUILD_DIR/* .

# Paso 6: Agregar y commitear los cambios
git add .
git commit -m "Deploy Flutter web app to GitHub Pages"

# Paso 7: Subir la rama gh-pages al repositorio remoto
git push origin $BRANCH --force

# Paso 8: Volver al directorio original y limpiar
cd ..
rm -rf $TMP_DIR

echo "Despliegue completado. Configura GitHub Pages para servir desde la rama $BRANCH."
