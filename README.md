## consigna del tp: 
https://docs.google.com/document/d/1ngXDE2ez-ztIsfwtkWnmAS3YSEobYEeRV0DU9r4TmRo/edit

## Cómo jugar

| Tecla | Acción |
|---|---|
| ↑ | Subir |
| ← → | Moverse a los costados |
| Enter | Empezar / nueva partida (en el game over y en la victoria vuelve al menú) |

La gravedad te baja una casilla cada medio segundo.

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
[Obstaculo|position|impactar(j);caer();image();afectar(j);imagenImpacto()]^-[Roca]
[Obstaculo]^-[Yunque]
[Obstaculo]^-[Nube]
[Obstaculo]^-[Globo]
[Obstaculo]^-[Escudo]
[≪interface≫;Impactable|impactar(jugador)]^-.-[Obstaculo]
[≪interface≫;Impactable]^-.-[Pinchos|position|impactar(j)]
[≪interface≫;Impactable]^-.-[Bomba|position;exploto|impactar(j)]
[≪interface≫;Impactable]^-.-[Decoracion|position|avanzar();image();impactar(j)]
[≪interface≫;Impactable]^-.-[Destello|position;image|impactar(j)]
[Decoracion]->[≪interface≫;Decorado|image();siguiente(posicion)]
[≪interface≫;Decorado]^-.-[≪object≫;pajaros]
[≪interface≫;Decorado]^-.-[≪object≫;estrellasFugaces]
[≪interface≫;Decorado]^-.-[≪object≫;cometas]
[≪object≫;efectos|destello(posicion,imagen)]->[Destello]


[≪object≫;jugador|position;vidas;estado|mover(dir);subir(n);bajar(n);recibirEmpuje(n);proteger();paralizar(ms);perderVida()]->[≪interface≫;EstadoJugador|image();puedeMoverse();recibirEmpuje(j,n);recuperarse(j)]
[≪interface≫;EstadoJugador]^-.-[≪object≫;normal]
[≪interface≫;EstadoJugador]^-.-[≪object≫;protegido]
[≪interface≫;EstadoJugador]^-.-[≪object≫;paralizado]


[≪object≫;juego|nivelActual;obstaculos;enCurso;peligrosDelPiso;decoraciones|nuevaPartida();iniciarNivel();nivelCompletado();perder(m)]->[Nivel|numero;msEntreApariciones;msDeCaida;fabricas;fondo;decorado|nuevoObstaculo()]
[Nivel]->[≪interface≫;Fabrica|crear(posicion)]
[Nivel]->[≪interface≫;Decorado]
[≪interface≫;Fabrica]^-.-[≪object≫;rocas]
[≪interface≫;Fabrica]^-.-[≪object≫;yunques]
[≪interface≫;Fabrica]^-.-[≪object≫;nubes]
[≪interface≫;Fabrica]^-.-[≪object≫;globos]
[≪interface≫;Fabrica]^-.-[≪object≫;escudos]

```

Para verlo, pegalo en https://yuml.me/diagram/scruffy/class/draw