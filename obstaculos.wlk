import wollok.game.*
import tablero.*
import juego.*

class Obstaculo {
  var property position

  method image()                  
  method afectar(unJugador)       

  method impactar(unJugador) {
    juego.quitarObstaculo(self)
    self.afectar(unJugador)
  }

  method caer() {
    position = position.down(1)
    if (tablero.llegoAlPiso(position)) {
      juego.quitarObstaculo(self)
    }
  }
}

// Empuja 2 casillas hacia abajo (el escudo lo frena)
class Roca inherits Obstaculo {
  override method image() = "roca.png"
  override method afectar(unJugador) { unJugador.recibirEmpuje(2) }
}

// atraviesa el escudo: baja 4 casillas sí o sí
class Yunque inherits Obstaculo {
  override method image() = "yunque.png"
  override method afectar(unJugador) { unJugador.bajar(4) }
}

// Lo paraliza unos segundos: no se puede mover, pero la gravedad sigue
class Nube inherits Obstaculo {
  override method image() = "nube.png"
  override method afectar(unJugador) { unJugador.paralizar(2000) }
}

//lo impulsa 3 casillas hacia arriba
class Globo inherits Obstaculo {
  override method image() = "globo.png"
  override method afectar(unJugador) { unJugador.subir(3) }
}

//lo protege del próximo empuje
class Escudo inherits Obstaculo {
  override method image() = "escudo.png"
  override method afectar(unJugador) { unJugador.proteger() }
}

// Fábricas: crean un obstaculo de cada tipo
object rocas   { method crear(posicion) = new Roca(position = posicion) }
object yunques { method crear(posicion) = new Yunque(position = posicion) }
object nubes   { method crear(posicion) = new Nube(position = posicion) }
object globos  { method crear(posicion) = new Globo(position = posicion) }
object escudos { method crear(posicion) = new Escudo(position = posicion) }

// saca una vida y el jugador vuelve a empezar desde abajo
class Pinchos {
  const property position
  method image() = "pinchos.png"
  method impactar(unJugador) { unJugador.perderVida() }
}

// Explota: se pierde la partida directamente
class Bomba {
  const property position
  var exploto = false

  method image() = if (exploto) "explosion.png" else "bomba.png"

  method impactar(unJugador) {
    exploto = true
    unJugador.perderTodasLasVidas()
  }
}
