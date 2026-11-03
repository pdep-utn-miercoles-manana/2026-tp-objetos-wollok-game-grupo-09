## consigna del tp: 
https://docs.google.com/document/d/1ngXDE2ez-ztIsfwtkWnmAS3YSEobYEeRV0DU9r4TmRo/edit

## Cómo jugar

| Tecla | Acción |
|---|---|
| ↑ | Subir |
| ← → | Moverse a los costados |
| R | Nueva partida |

La gravedad te baja una casilla cada 1,5 segundos.

| Obstáculo | Efecto |
|---|---|
| Roca | Te empuja 2 casillas hacia abajo (el escudo la frena) |
| Yunque | Te empuja 4 casillas hacia abajo, aunque tengas escudo |
| Nube | Te paraliza 2 segundos (la gravedad sigue actuando) |
| Globo | Te impulsa 3 casillas hacia arriba |
| Escudo | Te protege del próximo empuje |
| Pinchos en el piso | Perdés una vida y volvés a empezar desde abajo |
| Bomba en el piso | Explota y perdés la partida |

Nivel 1 (cielo) = rocas, globos y escudos -> 
Nivel 2 (estrellas) = se suman las nubes y todo cae más rápido ->
Nivel 3 (galaxia) = se suman los yunques, y es el más rápido.

## Iniciar juego

wollok run main.OvniUP

## Diagrama de Clases
```
[Obstaculo|position|impactar(j);caer();image();afectar(j)]^-[Roca]
[Obstaculo]^-[Yunque]
[Obstaculo]^-[Nube]
[Obstaculo]^-[Globo]
[Obstaculo]^-[Escudo]
[≪interface≫;Impactable|impactar(jugador)]^-.-[Obstaculo]
[≪interface≫;Impactable]^-.-[Pinchos|position|impactar(j)]
[≪interface≫;Impactable]^-.-[Bomba|position;exploto|impactar(j)]


[≪object≫;jugador|position;vidas;estado|mover(dir);subir(n);bajar(n);recibirEmpuje(n);proteger();paralizar(ms);perderVida()]->[≪interface≫;EstadoJugador|image();puedeMoverse();recibirEmpuje(j,n);recuperarse(j)]
[≪interface≫;EstadoJugador]^-.-[≪object≫;normal]
[≪interface≫;EstadoJugador]^-.-[≪object≫;protegido]
[≪interface≫;EstadoJugador]^-.-[≪object≫;paralizado]


[≪object≫;juego|nivelActual;obstaculos;enCurso;peligrosDelPiso|nuevaPartida();iniciarNivel();nivelCompletado();perder(m)]->[Nivel|numero;msEntreApariciones;msDeCaida;fabricas;fondo|nuevoObstaculo()]
[Nivel]->[≪interface≫;Fabrica|crear(posicion)]
[≪interface≫;Fabrica]^-.-[≪object≫;rocas]
[≪interface≫;Fabrica]^-.-[≪object≫;yunques]
[≪interface≫;Fabrica]^-.-[≪object≫;nubes]
[≪interface≫;Fabrica]^-.-[≪object≫;globos]
[≪interface≫;Fabrica]^-.-[≪object≫;escudos]

```

Para verlo, pegalo en https://yuml.me/diagram/scruffy/class/draw