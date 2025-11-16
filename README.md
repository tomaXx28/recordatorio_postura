#  App de Recordatorios de Postura  
Aplicación móvil desarrollada en **Flutter** que permite crear recordatorios para mejorar la postura 
Creada como proyecto de prueba tecnica por **Tomás Olea** para la compañia conecta mayor UC.

---

##  Características principales

- Crear recordatorios personalizados (título, descripción, fecha y hora).
- 20 posturas predeterminadas con textos pre-cargados.
- Pop-up automático que pregunta si realizaste la postura.
- "Omitir 5 minutos" con reprogramación y repeticiones automáticas.
- Evaluación constante cada 30 segundos (sin servicios en background).
- Filtrado por estado: **Todos, Pendientes, Completados, Omitidos**.
- Guardado local + sincronización con Firebase Firestore.
- Login y Registro usando **Firebase Auth**.
- Interfaz accesible para adultos mayores (tipografías grandes y claras).
- Edición y eliminación de recordatorios.
- Diseño moderno, limpio y responsivo.
- Crud de las tarjetas (Crear-Eliminar-Actualizar).

---

##  Tecnologías utilizadas

- **Flutter 3.x**
- **Dart**
- **Provider**
- **Firebase Auth**
- **Firestore Database**
- **Local Storage (SharedPreferences)**
- **flutter_local_notifications**
- **Timezone (tz)**

---

##  Requisitos previos

Antes de ejecutar el proyecto debes tener instalado:

- Flutter SDK  
- Android Studio o VS Code  
- Un dispositivo Android o emulador  
- Cuenta de Firebase  
- Git (opcional)

---

##  Instalación del proyecto

1. **Clonar este repositorio:**

```bash
git clone https://github.com/tomaXx28/recordatorio_postura.git
cd recordatorios_postura
```

2. **Instalar dependencias:**

```bash
flutter pub get
```

3. **Firebase:**
-  Para esto se le enviará un correo con una invitación al proyecto, por favor aceptarla
   así podrá ver como todo está conectado. 


4. **Configurar timezone:**

```bash
flutter pub run timezone:update
```

5. **Ejecutar el proyecto:**

```bash
flutter run
```

---

##  Cómo usar la aplicación

### 1. Registro / Inicio de sesión
- Crear cuenta con correo y contraseña.
- Iniciar sesión desde pantalla Login.

### 2. Crear un recordatorio
- Presiona el botón **+ Nuevo**.
- Selecciona postura o escribe una personalizada.
- Agrega fecha y hora.
- Guarda el recordatorio.

### 3. Popup inteligente
- Cuando llegue la hora del recordatorio → aparece popup.
- Opciones:
  - **Completado** → marca como completado.
  - **Omitir (5 min)** → reprograma +5 minutos y mantiene estado omitido.
- El popup reaparece cada 30 segundos mientras no se responda.

### 4. Filtrar recordatorios
Puedes filtrar por:
- Todos  
- Pendientes  
- Completados  
- Omitidos  

### 5. Editar / Eliminar
En el menú “⋮” de cada tarjeta:
- Editar  
- Eliminar  

---

> **“Aplicación móvil para mejorar la postura mediante recordatorios inteligentes y adaptativos”.**

Incluye:
- Lógica de notificaciones intentada e implementada
- Manejo completo de Firebase
- Evaluación periódica con Timer
- Popup persistente
- Diseño accesible para adultos mayores
- CRUD completo de recordatorios

.