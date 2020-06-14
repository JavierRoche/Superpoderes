He realizado todo sin usar los xib, definiendo, configurando y colocando individualmente cada elemento.
No he conseguido por mas vueltas que le he dado, sacar la informacion usando Core ML. Entiendo que habria que conseguir una estructura tipo diccionario (como la que hicimos en los ejercicios), y adaptar las respuestas de Vision y de Core ML a esta estructura. 
Pero bueno, creo que he avanzado y trasteado mucho con la concurrencia y la asincronia, y me comprometo a implementar la parte de CoreML para practicar Viper.

Funcionamiento:

- La app funciona tal y como indicas en la diapo, solo que yo he puesto la barra de busqueda encima del CollectionView, en la barra de navegacion.
- El boton de usar Vision o Core ML tambien esta añadido como right item en la barra de navegacion, aunque no switchea el modo, pues como he comentado Core ML no esta implementado.
- Me gustaria que me comentases que te parece que al final la custom queue la puse en el propio modelo, pues asi consegui el mejor rendimiento. Ademas, me aseguro del funcionamiento, porque como mientras esta con una predicción no entra otra, pues no puede terminar ninguna antes que la que esta en curso, ya que ni siquiera va a entrar. Aun así me gustaría que me comentases si te parece correcto