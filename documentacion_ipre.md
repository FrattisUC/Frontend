# IPRE para el desarrollo de una plataforma de cursos con corrector de pruebas integrado

## Integrantes del Equipo

- Cristian Ruz - Profesor Guía
- Francesca Lucchini - Supervisora General
- José Gutierrez - Desarrollador
- Sebastián Vásquez - Desarrollador (retirado)

Este ipre tiene como objetivo generar herramientas que permitan facilitar y mejorar la forma en como se enseña la ciencia de computación. Si bien inicialmente partió como la creación de un corrector de código, mediante pruebas unitarias, ha evolucionado a lo largo del tiempo para dar pie a la solución que actualmente se trabaja: adaptar una solución de software existente, [OKPY](https://github.com/okpy/ok), a las necesidad del DCC.

## Funcionamiento de OKPY

Esta sección tiene como objetivo introducir a OKPY. **Se recomienda encarezidamente** leer la [documentación oficial](https://github.com/okpy/ok/wiki) y el [GitHub](https://github.com/okpy) para tener un buen dominio de la aplicación, ya que este documento no es un manual sobre como utilizarlo ni como trabajar sobre el código.

OKPY sirve como una plataforma en donde distintos usuarios pueden descargar, subir y corregir pruebas de programación y computación. Se divide en tres módulos, todos ellos pertenecientes a la universidad de Berkeley, si bien solo dos de ellos son públicos: las aplicaciones cliente y servidor. El tercer módulo, el corrector, no se encuentra disponible de forma pública, por lo que queda a cargo del presente ipre en generar uno que pueda adaptarse a las otras dos aplicaciones.

### Módulo Cliente

[GitHub](https://github.com/okpy/ok-client)

El módulo cliente es un script de python que corre como una pseudo-CLI. Permite a los estudiantes entregar sus pruebas sin necesidad de conectarse a la aplicación web, corriendo solamente el script dentro de la carpeta de la tarea de programación. Permite corregir pruebas y subirlas a la plataforma web, si bien ambos no tienen por que ser al mismo tiempo.

El módulo cliente posee información sensible para el servidor, como claves API de acceso y URLs del servidor al cual debe ingresar las entregas de los estudiantes, pero como es compilado antes de ser entregado, tiene relativa seguridad para su posterior uso por parte del alumnado. Un alumno, al querer subir su prueba al servidor, debe autenticarse antes de poder completar todos los pasos.

### Módulo Servidor

[GitHub](https://github.com/okpy/ok)

El módulo servidor es una aplicación web que entrega una interfaz gráfica a alumnos, profesores y administradores para realizar la gestión de pruebas y cursos: Permite crearlos, registrar alumnos en ellos, generar pruebas de código para cada uno, realizar estadísticas de los distintos *submissions*, y mandarlos a corregir a un servidor corrector para poder obtener los puntajes de cada uno. Si bien la app es relativamente compleja, los principales modelos son 3: Usuarios, Cursos y Tareas.

#### Usuarios

Existen tres tipos de usuarios en OK: estudiantes, encargados (ya sea profesor o ayudante) y administradores. Cada uno tiene al menos los mismo privilegios y accesos que los anteriores, y puede ocurrir que un usuario sea de más de un tipo a la vez (un alumno puede ser ayudante o profesor de otro ramo). Una de las grandes ventajas de OK es que permite limitar el acceso a los recursos según las atribuciones de cada usuario.

#### Cursos

Los cursos son instancias, dirigidas por almenos un encargado, donde los alumnos pueden ser inscritos para rendir pruebas, ya sea de forma individual o grupal. Actualmente su funcionamiento es sencillo, si bien permite obtener estadísticas de los alumnos y pruebas, además de descargar *submissions* para su revisión manual o bien mandarlas al corrector externo.

#### Tareas

Una tarea se considera como una instancia que indica a distintos grupos, de almenos un alumno, qué deben realizar, además de que cosas deben subir a la aplicación web. Actualmente está muy ligado con el módulo cliente, debido a que una forma de corregir tareas en mediante el uso de este, si bien puede realizarse "a mano" sin ayuda del módulo cliente. Un alumno puede subir muchas *submissions* a la plataforma, debiendo indicar cual es la que se debe corregir.

## Cómo integrar un corrector externo

Para realizar la conexion con la aplicación correctora, basta establecer la variable de entorno AUTOGRADER_URL, o bien ir al archivo *server/constants.py*, del repositorio del servidor,y configurar la variable ahí mismo.

Es importante destacar que esta configuración general de la url puede ser supeditada por la configuración especifica de cada curso: si uno va a la pagina de configuraciones de un curso (por ejemplo http://localhost:5000/admin/course/1/settings), puede configurar la variable Autograder Endpoint, que permite revisar las tareas en un corrector aparte.

Es importante destacar que el nuevo corrector a integrar va a funciona de forma distinta al flujo actual que tiene la aplicación, razon por la cual se han tenido que implementar cambios en el servidor (dejando las funcionalidades antiguas, en caso de necesitarlas más adelante). Su funcionamiento general se detalla en un archivo adjunto, si bien en caso de necesitar más detalle será necesario consultar con el encargado del corrector, José Gutierrez.

En el archivo *frattisdocs.md* se encuentra un primer borrador de como será la API del corrector, además de la estructura de archivos que será necesario enviar en los requests para la corrección de pruebas. Se espera que los futuros cambios implementen ese sistema, de forma de lograr una integración lo más fluida posible entre plataformas.

Actualmente los métodos relevantes para la comunicación con el servidor corrector están en los archivos *server/autograder.py* y *server/controllers/admin.py*. Agregando un botón "Send to Frattis Autograder", se permite automatizar la generación del job que busca las submissions correspondientes, y sube los archivos *info.json* y *test.json* para realizar el request correspondiente al servidor backend. Dentro de *autograder* y *admin* se deben buscar los métodos con la forma frattis_*(), que son los asociados a la comunicación con el backend.

Actualmente el job, debido a cómo está diseñado por el equipo de OKPY, se queda esperando la respuesta del servidor, con las pruebas ya corregidas, para retornar los resultados para su posterior visualización en el browser. Según el documento *frattisdocs.md* , se ajustará este comportamiento para que el servidor corrector entregue un id de solicitud, para poder utilizar a futuro ese id para revisar si un submission ha sido corregido o no. Sin embargo, si el equipo de desarrollo considera que es mejor forma mantener la arquitectura actual, esto se puede hacer sin mayores contratiempos.

## Trabajo Pendiente

El trabajo pendiente puede resumirse como la comunicación y recepción de las pruebas (y sus correspondientes resulados) con el servidor autograder. Sin embargo, hay dos formas posibles de abordar el trabajo pendiente, ambas viables con la arquitectura actual:

1. Crear un job que realice de forma asincrona la solicitud de corrección, y se quede en espera hasta que el corrector termine de revisar.

2. Enviar una solicitud [POST] al autograder, que este devuelva un *submission_id*, el cual sea utilizado después en otro método para recuperar los resultados en caso que estén listos.

Ambos caminos son viables, pero dependerán de los acuerdos que se generen en nuevas instancias del ipre.

En caso de decantarse por la primera opción, se deberán realizar las siguientes sub-tareas:

- Utilizar la actitectura de jobs presente en OKPY de forma que envíe las pruebas según el formato pedido.

- Una vez devuelto el resultado, se debe realizar el procesamiento de estos para generar datos útiles.

- Mostrar estos datos en alguna vista.

En caso de decidir la segunda opción, las principales sub-tareas son:

- Crear un modelo que permita guardar el id de una tarea enviada al autograder.

- Enviar una solicitud [POST] al autograder, y guardar la respuesta en este nuevo modelo.

- Crear un método que permita, para una tarea dada, consultar el resultado del autograder.

- Una vez devuelto el resultado, se debe realizar el procesamiento de estos para generar datos útiles.

- Mostrar estos datos en alguna vista.

## Casos a considerar

- Hay que revisar que cuando se haga un request, este no se envíe si ya existe un request para ese alumno / tarea ya en proceso (evitar que un usuario no pueda spamear 1000 requests de la misma tarea)
