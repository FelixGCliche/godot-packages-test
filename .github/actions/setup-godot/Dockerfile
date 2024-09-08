FROM ubuntu:jammy

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/godotengine/godot/releases/download/${INPUT_GODOT-VERSION}-${INPUT_GODOT-PATCH-VERSION}/Godot_v${INPUT_GODOT-VERSION}-${INPUT_GODOT-PATCH-VERSION}_linux.x86_64.zip > godot.zip
RUN curl -L https://github.com/godotengine/godot/releases/download/${INPUT_GODOT-VERSION}-${INPUT_GODOT-PATCH-VERSION}/Godot_v${INPUT_GODOT-VERSION}-${INPUT_GODOT-PATCH-VERSION}_export_templates.tpz > templates.tpz

RUN unzip godot.zip
RUN unzip templates.tpz

RUN mkdir -vp ~/.local/share/godot/export_templates/${INPUT_GODOT-VERSION}.${INPUT_GODOT-PATCH-VERSION}
RUN mv templates/* ~/.local/share/godot/export_templates/${INPUT_GODOT-VERSION}.${INPUT_GODOT-PATCH-VERSION}
RUN mv Godot_v${INPUT_GODOT-VERSION}-${INPUT_GODOT-PATCH-VERSION}_linux.x86_64 /usr/local/bin/godot


RUN rm -R templates/
RUN rm templates.tpz godot.zip
# ENTRYPOINT [ "/entrypoint.sh" ]