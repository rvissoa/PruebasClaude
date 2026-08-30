# Chispa el Dragón 🐉

Juego arcade de un toque (estilo Flappy Bird) para niños de 7-10 años. Ayudá a
Chispa a volar entre pilares de cristal mágico, juntar gemas y desbloquear
dragones de distintos elementos.

## Cómo jugar
- **Tocar la pantalla** (o clic / barra espaciadora en escritorio) para aletear.
- Esquivar los pilares de cristal.
- Juntar gemas doradas que aparecen en algunos huecos.
- Las gemas se guardan entre partidas y se gastan en la Tienda para
  desbloquear dragones: Fuego (inicial), Hielo, Bosque, Tormenta, Dorado.

## Requisitos
- [Godot Engine 4.3+](https://godotengine.org/download) (versión estándar, no
  necesita el build de .NET/C# ya que todo el código está en GDScript).

## Cómo abrir y probar
1. Abrí Godot Engine.
2. "Import" → seleccioná la carpeta `chispa-el-dragon/` (el archivo `project.godot`).
3. Presioná el botón de Play (▶) en la esquina superior derecha del editor.

> **Nota importante**: este proyecto fue generado sin acceso a un editor de
> Godot para probarlo visualmente, así que puede tener algún detalle a
> ajustar la primera vez que lo abras (posiciones de UI, balance de
> dificultad, etc.). Todo el código está comentado y organizado para que sea
> fácil de corregir — contame qué ves al abrirlo y lo iteramos.

## Estructura del proyecto
```
chispa-el-dragon/
├── project.godot          # configuración del proyecto (Godot 4)
├── icon.svg                # ícono placeholder
├── scenes/
│   └── Main.tscn            # única escena real: arranca todo desde código
└── scripts/
    ├── GameState.gd         # autoload: puntaje, gemas, skins, guardado
    ├── Main.gd               # orquesta menú / juego / game over / tienda
    ├── Dragon.gd              # personaje jugable
    ├── Obstacle.gd            # pilares + zona de puntaje + gema
    ├── Background.gd          # cielo y nubes (dibujado por código)
    ├── HUD.gd                  # puntaje y gemas en pantalla
    ├── MainMenu.gd             # menú principal
    ├── GameOver.gd             # pantalla de fin de partida
    └── Shop.gd                  # tienda de dragones
```

No usa imágenes ni sonidos externos todavía: todo el arte (dragón, pilares,
nubes) se dibuja por código con formas simples, así que corre sin depender de
assets. Es un buen punto de partida para reemplazar por arte final más
adelante (sprites, animaciones, música, efectos de sonido).

## Cómo publicarlo en Android e iOS

Estos pasos requieren herramientas fuera de este entorno (no se pueden hacer
solo con código):

### Android
1. Instalá Android Studio (para el SDK) y Java (JDK 17+).
2. En Godot: **Editor → Administrar plantillas de exportación** → descargar
   las plantillas de exportación de Godot 4.
3. **Proyecto → Exportar** → agregar preset "Android" → configurar el SDK y
   generar/asignar un keystore para firmar la app.
4. Exportar como `.apk` (para probar) o `.aab` (para subir a Google Play).

### iOS
1. Necesitás una Mac con Xcode instalado y una cuenta de Apple Developer
   (para firmar y subir a la App Store).
2. En Godot: agregar preset "iOS" en **Proyecto → Exportar**, configurar el
   Bundle Identifier y el equipo de firma.
3. Godot exporta un proyecto de Xcode; desde ahí se compila, se firma y se
   sube con Xcode o Transporter a App Store Connect.

## Próximos pasos sugeridos
- Reemplazar las formas dibujadas por sprites/animaciones reales.
- Agregar música de fondo y efectos de sonido (aleteo, choque, recolectar gema).
- Ajustar la curva de dificultad jugando varias partidas.
- Sumar más skins de dragón o power-ups simples (escudo, imán de gemas).
