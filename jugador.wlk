import wollok.game.*
import tablero.*
import juego.*

object jugador {
  const vidasIniciales = 3
  var property position = tablero.posicionInicial()
  var property vidas = vidasIniciales
  var property estado = normal

  method image() = estado.image()

  // ---- Movimiento ----
  method mover(direccion) {
    if (estado.puedeMoverse()) {
      self.irA(direccion.siguiente(position))
    }
  }

  method subir(casillas)  { self.irA(position.up(casillas)) }
  method bajar(casillas)  { self.irA(position.down(casillas)) }
  method caer()           { self.bajar(1) }   // gravedad

  method irA(nuevaPosicion) {
    position = tablero.posicionValida(nuevaPosicion)
    if (tablero.llegoALaMeta(position)) {
      juego.nivelCompletado()
    }
  }

  // ---- Efectos obstaculos ----
  method recibirEmpuje(casillas) { estado.recibirEmpuje(self, casillas) }
  method proteger() { estado = protegido }

  method paralizar(milisegundos) {
    estado = paralizado
    game.schedule(milisegundos, { estado.recuperarse(self) })
  }

  method perderVida() {
    vidas = 0.max(vidas - 1)
    if (self.sinVidas()) {
      juego.perder("¡Te quedaste sin vidas!")
    } else {
      self.reaparecer()
    }
  }

  method perderTodasLasVidas() {
    vidas = 0
    juego.perder("¡BOOM!")
  }

  method sinVidas() = vidas == 0

  method reaparecer() {
    position = tablero.posicionInicial()
    estado = normal
  }

  method reiniciar() {
    vidas = vidasIniciales
    self.reaparecer()
  }
}

// ---- Estados del jugador ----

object normal {
  method image() = "jugador.png"
  method puedeMoverse() = true
  method recibirEmpuje(unJugador, casillas) { unJugador.bajar(casillas) }
  method recuperarse(unJugador) { }
}

object protegido {
  method image() = "jugador_escudo.png"
  method puedeMoverse() = true
  // El escudo absorbe el empuje y se gasta
  method recibirEmpuje(unJugador, casillas) { unJugador.estado(normal) }
  method recuperarse(unJugador) { }
}

object paralizado {
  method image() = "jugador_paralizado.png"
  method puedeMoverse() = false
  method recibirEmpuje(unJugador, casillas) { unJugador.bajar(casillas) }
  method recuperarse(unJugador) { unJugador.estado(normal) }
}
