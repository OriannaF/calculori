# 🧮 CalculOri

> App ágil e intuitiva para calcular precios de venta con múltiples métodos de cobro. Desarrollada 100% en **Flutter**.

---

## ✨ Capacidades Principales

* 🚀 **Onboarding de 4 pasos:** Configuración inicial rápida que incluye el nombre del local, método de cálculo (margen % o multiplicador x), métodos de cobro (con recargos o descuentos) y formato de moneda/IVA.
* 🧮 **Calculadora de precios:** Ingresá el costo de tu producto y la app aplica automáticamente el margen y el redondeo configurado.
* 💳 **Múltiples métodos de cobro:** Soporte para efectivo, transferencia, tarjeta, y precio mayorista. Cada método cuenta con su propio recargo o descuento personalizable.
* 🕒 **Historial inteligente:** Guardá, consultá y buscá cálculos anteriores por nombre. También podés eliminar registros individualmente.
* 📤 **Compartir fácil:** Capturá la tarjeta de precios como imagen y compartila al instante por cualquier app de mensajería o red social.
* 🏪 **Perfil del negocio:** Personalizá la app con el nombre y la foto de perfil de tu emprendimiento (editable directamente desde la pantalla principal).
* ⚙️ **Configuración avanzada:** Ajustá la lógica base de cálculo, las reglas de redondeo y gestioná un CRUD completo de tus métodos de cobro.
* 💾 **Persistencia local:** Todos tus datos y configuraciones se guardan de forma segura en el dispositivo mediante `SharedPreferences`.
* 🌍 **Multi-moneda:** Soporte nativo para ARS, USD, BRL, CLP, MXN, COP y EUR.
* 🔢 **Multi-formato numérico:** Elegí entre el formato argentino (`1.234,56`) o el formato US (`1,234.56`).

---

## 🛠️ Tecnologías y Paquetes

Este proyecto utiliza las siguientes dependencias clave en el ecosistema de Flutter:

| Paquete | Uso |
| :--- | :--- |
| **`flutter_riverpod`** | Gestión del estado de la aplicación de forma reactiva y escalable. |
| **`shared_preferences`** | Persistencia de datos locales (configuraciones, historial, perfil). |
| **`screenshot`** + **`share_plus`** | Captura de widgets a imagen y funcionalidad para compartir con otras apps. |
| **`image_picker`** | Selección de la foto de perfil del negocio desde la galería o cámara. |
| **`device_preview`** | Herramienta para previsualizar la UI en diferentes tamaños de pantalla. |

---

## 📋 Requisitos Previos

Asegurate de tener instalado lo siguiente en tu entorno de desarrollo antes de clonar el proyecto:

* **Flutter SDK:** `^3.11`
* **Dart SDK:** `^3.11`

---

## 🚀 Ejecución y Despliegue

Para levantar el proyecto en tu máquina local, seguí estos comandos:

### 📱 Mobile (Android / iOS)
Para ejecutar la aplicación en un emulador o dispositivo físico conectado:

```bash
flutter run
