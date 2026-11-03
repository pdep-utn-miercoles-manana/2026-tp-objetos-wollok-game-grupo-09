import wollok.game.*
import tablero.*
import juego.*

object pajaros {
  method image() = "pajaro.png"
  method siguiente(posicion) = derecha.siguiente(posicion)
}

object estrellasFugaces {
  method image() = "estrella_fugaz.png"
  method siguiente(posicion) = diagonalAbajo.siguiente(posicion)
}

object cometas {
  method image() = "cometa.png"
  method siguiente(posicion) = derecha.siguiente(posicion)
}

// Cruza el fondo sin afectar al jugador
class Decoracion {
  var property position

  method image() = self.decorado().image()
  method decorado() = juego.nivelActual().decorado()

  method avanzar() {
    position = self.decorado().siguiente(position)
    if (tablero.salioDelAreaDeJuego(position)) {
      position = tablero.posicionAlAzarIzquierda()
    }
  }

  method impactar(unJugador) { }
}

// ---------------- Efectos ----------------
object efectos {
  const duracionDestello = 300

  method destello(posicion, imagen) {
    const destello = new Destello(position = posicion, image = imagen)
    game.addVisual(destello)
    game.schedule(duracionDestello, { self.quitar(destello) })
  }

  method quitar(visual) {
    if (game.hasVisual(visual)) {
      game.removeVisual(visual)
    }
  }
}

// Marca por un instante dónde golpeó un obstáculo
class Destello {
  const property position
  const property image

  method impactar(unJugador) { }
}
