# Sistema de Gestión de Precios y Finanzas

Solución de software de escritorio desarrollada en **Flutter** y **Dart**, diseñada para optimizar la toma de decisiones comerciales y el control financiero analítico.

---

## 💡 Propuesta de Valor y Capacidades del Sistema

En el entorno minorista actual, la falta de control sobre los márgenes de ganancia, la dispersión del flujo de caja entre efectivo y billeteras virtuales, y la ausencia de métricas claras de rentabilidad dificultan la administración de los pequeños negocios. Este sistema resuelve dicha problemática centralizando la gestión operativa en cuatro componentes clave:

* **Calculadora de Precios:** Cálculo algorítmico en tiempo real para determinar precios de venta óptimos por kilo o unidad.
* **Control de Caja Ágil (POS):** Registro de flujos optimizado para la navegación fluida con teclado. Unifica ingresos (efectivo/transferencias) y centraliza los egresos, manteniendo un panel visual con el historial inmediato.
* **Arqueo Diario Detallado:** Desglose exacto de saldos por medio de pago y registro cronológico de todos los movimientos del día, eliminando la pérdida de información por "gastos hormiga".
* **Reportes y Balances:** Motor de agregación que cruza datos por rangos de fechas para consolidar el balance neto real, con visualización en tabla y exportación directa a formato PDF.

---

## 🏗️ Enfoque Técnico: Arquitectura Hexagonal

Para garantizar la mantenibilidad y escalabilidad, el software respeta estrictamente los principios de la **Arquitectura Hexagonal (Puertos y Adaptadores)**, distribuyendo el código en tres capas con regla de dependencia hacia el centro:

* **Dominio (`/dominio`):** Contiene los modelos puros de negocio e interfaces de los puertos de salida, escritos en Dart nativo y aislados de cualquier framework o librería externa.
* **Aplicación (`/aplicacion`):** Aloja los Casos de Uso independientes que ejecutan la lógica e interactúan con el dominio mediante inyección e inversión de dependencias.
* **Infraestructura (`/infraestructura`):** Interfaz gráfica en Flutter y adaptadores de datos. Implementa **SQLite** local, lo que permite persistir la información de manera robusta sin alterar las reglas de negocio esenciales.

---

## 🛠️ Stack Tecnológico Completo

* **Flutter:** Framework principal para garantizar una interfaz de escritorio ágil y adaptada a resoluciones amplias.
* **Dart:** Lenguaje base para el núcleo táctico.
* **SQLite:** Base de datos relacional integrada para la persistencia local y segura de la información financiera.
* **Git & GitHub:** Herramientas para el control de versiones y el respaldo del código.
* **VS Code:** Entorno de desarrollo principal optimizado para Flutter.
* **OpenCode:** Herramienta clave para optimizar y agilizar el flujo de desarrollo.

---

## 🚀 Estado del Proyecto

* **Fase 1 (MVP Inicial - Completado):** Implementación de Arquitectura Hexagonal con persistencia en SQLite. Módulos funcionales de Calculadora, Caja (UX optimizada), Arqueo Diario, Reportes por Período y Exportación a PDF.
* **Fase 2 (Backlog):** Control de inventario físico de productos, integración con balanzas electrónicas y sincronización en la nube o arquitectura cliente-servidor multidispositivo.