# Diseño e Implementación de Plan Integral de Ciberseguridad

## Descripción

Este proyecto corresponde al desarrollo de un **Plan Integral de Ciberseguridad**, enfocado en la implementación de buenas prácticas de seguridad informática y la automatización de controles de seguridad dentro del ciclo de desarrollo de software (DevSecOps).

Como parte del proyecto se implementaron mecanismos de análisis automatizado del código fuente mediante **GitHub Actions**, permitiendo ejecutar verificaciones de seguridad de manera continua durante el proceso de desarrollo.

---

## Objetivo General

Diseñar e implementar un plan integral de ciberseguridad que incorpore controles preventivos y automatizados para fortalecer la seguridad del desarrollo de software y reducir los riesgos asociados a vulnerabilidades y exposición de información sensible.

---

## Objetivos Específicos

- Implementar un flujo de integración continua utilizando GitHub Actions.
- Automatizar el análisis estático del código fuente.
- Detectar vulnerabilidades en dependencias del proyecto.
- Identificar credenciales o secretos expuestos dentro del repositorio.
- Aplicar principios de DevSecOps dentro del ciclo de desarrollo.

---

## Tecnologías Utilizadas

- Python
- Git
- GitHub
- GitHub Actions
- Semgrep
- Trivy
- Gitleaks
- Visual Studio Code

---

## Automatizaciones Implementadas

El proyecto incorpora tres procesos automatizados de seguridad ejecutados mediante GitHub Actions:

### Semgrep

Análisis estático del código (SAST) para detectar errores de programación, malas prácticas y posibles vulnerabilidades de seguridad.

### Trivy

Escaneo automático de vulnerabilidades presentes en dependencias y componentes utilizados por la aplicación.

### Gitleaks

Detección de credenciales, claves API, contraseñas y otros secretos que puedan ser expuestos accidentalmente en el repositorio.

---

## Flujo de Automatización

```
Desarrollador
      │
      ▼
 Git Push / Pull Request
      │
      ▼
 GitHub Actions
      │
 ├──────────────┐
 ▼              ▼
Semgrep      Trivy
      │
      ▼
 Gitleaks
      │
      ▼
 Reportes de Seguridad
```

---

## Estructura del Proyecto

```
creatic-zero-trust-security/
│
├── .github/
│   └── workflows/
│       ├── semgrep.yml
│       ├── trivy.yml
│       └── gitleaks.yml
│
├── src/
├── docs/
├── README.md
└── requirements.txt
```

---

## Resultados

Durante el desarrollo del proyecto se logró:

- Automatizar controles de seguridad dentro del repositorio.
- Implementar un pipeline DevSecOps funcional.
- Ejecutar análisis automáticos en cada actualización del código.
- Detectar vulnerabilidades potenciales antes de la integración del software.
- Fortalecer las buenas prácticas de desarrollo seguro.

---

## Posibles Mejoras Futuras

- Integración con SIEM.
- Implementación de escaneo de imágenes Docker.
- Integración con SonarQube.
- Despliegue automatizado mediante CI/CD.
- Notificaciones automáticas por correo o Microsoft Teams.
- Integración con herramientas de monitoreo y respuesta ante incidentes.

---

## Integrantes

- Diego Casis
- John Hou
- Cecydi Bethancourt

---

## Información Académica

**Universidad Tecnológica de Panamá**

**Facultad de Ingeniería de Sistemas Computacionales**

**Maestría en Ciencias Computacionales**

**Asignatura:** Tópicos Especiales II

**Profesor:** Xavier Trujillo

**Grupo:** 1M3213

---

## Licencia

Proyecto desarrollado con fines académicos.