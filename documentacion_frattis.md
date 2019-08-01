# Documentación API Servicio de Corrección de Pruebas

Esta documentación es tentativa, y está sujeta a cambios por parte del equipo de desarrollo del ipre.

## Flujo de la Comunicación

- Server emite un [POST] al autograder, con el siguiente contenido:

```JSON
{
    headers: {
        authorization: JWT-token,
    }
    body: {
        file: assignment.zip
    }
}
```

- Ante una respuesta positiva, se recibe la siguiente response:

```JSON
{
    headers: {
        status_code: 200
    }
    body: {
        assignment_id: 12345 # Utilizado para consultar sobre el estado de este assignment en particular.
    }
}
```

- Al querer consultar el estado de un assignment, se hace un [GET] al autograder, con el siguiente contenido:

```JSON
{
    headers: {
        authorization: JWT-token,
    }
    body: {
        assignment_id: 12345
    }
}
```

- Primer caso: Assignment revisado completamente, en donde la respuesta tendrá el siguiente formato:

```JSON
{
    headers: {
        status_code: 200
    },
    body: {
        scores: scores.zip
    }
}
```

- Segundo caso: Assignment no está revisado todavía, en donde la respuesta tendrá el siguiente formato:

```JSON
{
    headers: {
        status_code: 204
    },
    body: {
        message: "Assignment's not ready yet."
    }
}
```

- Tercer caso: Assignment no existe, en donde la respuesta tendrá el siguiente formato:

```JSON
{
    headers: {
        status_code: 404
    },
    body: {
        message: "Assignment does not exist."
    }
}
```

## Estructura de los distintos archivos y carpetas

### Estructura de .zip a entregar al grader

- Carpeta (.zip) con nombre "assignment"
  - Sub Carpeta "submissions"
    - Una Sub Carpeta por Alumno (nombre alumno - mail)
      - Contenido del submission
  - Archivo Info, con la info del assignment
  - Archivo Test, con formato definido más abajo

### Formato de un Archivo "Info"

```JSON
{
  "user": "test", # Quien mandó a corregir
  "name": "Division", # Nombre del Assignment
  "file": "division.py" # Nombre del archivo a corregir dentro de cada Submission
}
```

### Formato de un Archivo "Test"

```JSON
{
  "test_0": {   # Nombre del test
    "input": [1, 3], # Cuales son los inputs a probar
    "output": ["Ingrese dos numeros.", 0.33] # Outputs esperados para cada input. OJO: PRIMER ELEMENTO DE CADA OUTPUT ES EL PROMPT.
  },
  "test_1": {
    "input": [-2,3],
    "output": ["Ingrese dos numeros.", -0.66]
  },
  "test_err": {
    "input": [5, 0],
    "output": ["Ingrese dos numeros.", "Error"]
  },
  "bad_test": {
    "input": [5, 5],
    "output": ["Ingrese dos numeros.", 2]
  }

}
```

### Formato de un archivo scores.js

```JSON
{
    "username_1":
    {
        "test_0":
        {
            "sts": 1,
            "ext": 0
        }
    },
    ...
}
```
