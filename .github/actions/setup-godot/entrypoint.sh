#!/bin/sh -l
echo "Godot Version: $1.$2"
curl -L https://github.com/godotengine/godot/releases/download/$1-$2/Godot_v$1-$2_linux.x86_64.zip > godot.zip
curl -L https://github.com/godotengine/godot/releases/download/$1-$2/Godot_v$1-$2_export_templates.tpz > templates.tpz

unzip godot.zip
unzip templates.tpz

mkdir -vp ~/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_PATCH_VERSION}
mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${GODOT_PATCH_VERSION}

mv Godot_v${GODOT_VERSION}-${GODOT_PATCH_VERSION}_linux.x86_64 /usr/local/bin/godot

rm -R templates/
rm templates.tpz godot.zip
ls -la /usr/local/bin