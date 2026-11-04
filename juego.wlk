import wollok.game.*
import tablero.*
import jugador.*
import obstaculos.*
import decorado.*

class Nivel {
  const property numero
  const property msEntreApariciones   // cada cuánto aparece un obstáculo
  const property msDeCaida            // cada cuánto bajan una casilla
  const fabricas                      // qué obstáculos pueden aparecer (repetir = más probable)
  const property fondo                // imagen de fondo: cuanto más alto el nivel, más lejos se llega
  const property decorado             // lo que cruza el fondo mientras se juega

  method nuevoObstaculo() = fabricas.anyOne().crear(tablero.posicionAlAzarArriba())
}

object juego {
  const msGravedad = 500
  const msDecorado = 700
  const msAntesDelCartel = 800       // deja ver la explosión antes del game over
  const eventos = ["aparecer", "caer", "gravedad", "decorado"]

  const niveles = [
    new Nivel(numero = 1, msEntreApariciones = 700, msDeCaida = 400,
              fabricas = [rocas, rocas, rocas, globos, escudos],
              fondo = "fondo_cielo.png", decorado = pajaros),
    new Nivel(numero = 2, msEntreApariciones = 500, msDeCaida = 200,
              fabricas = [rocas, rocas, rocas, nubes, nubes, globos, escudos],
              fondo = "fondo_estrellas.png", decorado = estrellasFugaces),
    new Nivel(numero = 3, msEntreApariciones = 200, msDeCaida = 100,
              fabricas = [rocas, rocas, yunques, yunques, nubes, nubes, globos, escudos],
              fondo = "fondo_galaxia.png", decorado = cometas)
  ]

  var property nivelActual = niveles.first()
  const property obstaculos = []
  const peligrosDelPiso = []
  const decoraciones = [
    new Decoracion(position = game.at(2, 10)),
    new Decoracion(position = game.at(-8, 5))   // arranca afuera: entra más tarde
  ]
  var property enCurso = false
  var property mensaje = ""
  var estado = "cargando"
  var cartelVisible = false

  method estaEnMenu() = estado == "menu"
  method estaPerdido() = estado == "perdido"
  method estaGanado() = estado == "ganado"
  method estaCargando() = estado == "cargando"

  // ---------------- Configuración ----------------
  method configurar() {
    game.title("Ovni UP")
    game.width(tablero.ancho())
    game.height(tablero.alto())
    game.cellSize(40)
    self.cambiarANivel(niveles.first())
    decoraciones.forEach({ decoracion => game.addVisual(decoracion) })   // antes que el jugador: quedan detrás
    game.addVisual(jugador)
    hud.mostrar()
    self.configurarTeclas()
    game.addVisual(cartelCarga)
    game.schedule(5000, { self.finalizarCarga() })
    game.onCollideDo(jugador, { algo => algo.impactar(jugador) })
  }

  method configurarTeclas() {
    keyboard.up().onPressDo({ self.moverJugador(arriba) })
    keyboard.left().onPressDo({ self.moverJugador(izquierda) })
    keyboard.right().onPressDo({ self.moverJugador(derecha) })
    keyboard.enter().onPressDo({ self.presionarEnter() })
  }

  method moverJugador(direccion) {
    if (enCurso) {
      jugador.mover(direccion)
    }
  }

  method presionarEnter() {
    if (self.estaGanado()) {
      self.volverAlMenu()
    } else if (self.estaEnMenu() || self.estaPerdido()) {
      self.nuevaPartida()
    }
  }

  method volverAlMenu() {
    estado = "menu"
    mensaje = ""
    self.cambiarANivel(niveles.first())
    jugador.reiniciar()
  }

method mostrarCartel() {
    if (!cartelVisible) {
      game.addVisual(cartel)
      cartelVisible = true
    }
  }

   method ocultarCartel() {
    if (cartelVisible) {
      game.removeVisual(cartel)
      cartelVisible = false
    }
  }
method finalizarCarga() {
  if (self.estaCargando()) {
    estado = "menu"
    game.removeVisual(cartelCarga)
    self.mostrarCartel()
  }
}



  // ---------------- Partida y niveles ----------------

  method nuevaPartida() {
    estado = "jugando"
    mensaje = ""
    self.ocultarCartel()
    self.cambiarANivel(niveles.first())
    jugador.reiniciar()
    self.armarPiso()
    self.iniciarNivel()
  }
  
  method armarPiso() {
    peligrosDelPiso.forEach({ peligro => game.removeVisual(peligro) })
    peligrosDelPiso.clear()
    (0 .. tablero.ancho() - 1).forEach({ x =>
      const peligro = self.peligroParaColumna(x)
      peligrosDelPiso.add(peligro)
      game.addVisual(peligro)
    })
  }

  method peligroParaColumna(x) {
    const posicion = game.at(x, tablero.filaPiso())
    return if (x % 4 == 1) new Bomba(position = posicion) else new Pinchos(position = posicion)
  }

  method cambiarANivel(nivel) {
    nivelActual = nivel
    game.boardGround(nivel.fondo())
  }

  method iniciarNivel() {
    self.detenerEventos()
    self.limpiarObstaculos()
    self.ocultarCartel()
    jugador.reaparecer()
    mensaje = ""
    estado = "jugando"
    enCurso = true
    game.onTick(nivelActual.msEntreApariciones(), "aparecer", { self.agregarObstaculo(nivelActual.nuevoObstaculo()) })
    game.onTick(nivelActual.msDeCaida(), "caer", { obstaculos.copy().forEach({ obstaculo => obstaculo.caer() }) })
    game.onTick(msGravedad, "gravedad", { jugador.caer() })
    game.onTick(msDecorado, "decorado", { decoraciones.forEach({ decoracion => decoracion.avanzar() }) })
  }

  method nivelCompletado() {
    self.pausar()
    if (self.esUltimoNivel()) {
      estado = "ganado"
      self.terminar("¡GANASTE!")
      self.mostrarCartel()
    } else {
      estado = "transicion"
      self.cambiarANivel(self.siguienteNivel())
      mensaje = "¡Nivel superado!"
      self.mostrarCartel()
      game.schedule(1500, { self.iniciarNivel() })
    }
  }

  method perder(motivo) {
    self.pausar()
    estado = "perdido"
    self.terminar(motivo)
    game.schedule(msAntesDelCartel, { if (self.estaPerdido()) self.mostrarCartel() })
  }

  method terminar(texto) {
    mensaje = texto
  }

  method pausar() {
    enCurso = false
    self.detenerEventos()
    self.limpiarObstaculos()
  }

  method esUltimoNivel() = nivelActual.numero() == niveles.size()
  method siguienteNivel() = niveles.get(nivelActual.numero())   // los números empiezan en 1

  method detenerEventos() {
    eventos.forEach({ evento => game.removeTickEvent(evento) })
  }

  // ---------------- Obstáculos ----------------
  method agregarObstaculo(obstaculo) {
    obstaculos.add(obstaculo)
    game.addVisual(obstaculo)
  }

  method quitarObstaculo(obstaculo) {
    if (obstaculos.contains(obstaculo)) {
      obstaculos.remove(obstaculo)
      game.removeVisual(obstaculo)
    }
  }

  method limpiarObstaculos() {
    obstaculos.copy().forEach({ obstaculo => self.quitarObstaculo(obstaculo) })
  }
}

// ---------------- Barra superior ----------------
object hud {
  const property corazones = [new CorazonHud(indice = 0), new CorazonHud(indice = 1), new CorazonHud(indice = 2)]

  method mostrar() {
    game.addVisual(barraHud)
    game.addVisual(nivelHud)
    corazones.forEach({ corazon => game.addVisual(corazon) })
    game.addVisual(mensajeHud)
  }
}

object barraHud {
  method position() = game.at(0, tablero.filaHud())
  method image() = "hud_barra.png"
}

object nivelHud {
  method position() = game.at(0, tablero.filaHud())
  method image() = "hud_nivel" + juego.nivelActual().numero() + ".png"
}

class CorazonHud {
  const indice   // 0, 1, 2: está lleno si al jugador le quedan más vidas que su índice
  method position() = game.at(tablero.ancho() - 3 + indice, tablero.filaHud())
  method image() = if (jugador.vidas() > indice) "hud_corazon.png" else "hud_corazon_vacio.png"
}

object mensajeHud {
  method position() = game.at(tablero.columnaCentral(), tablero.filaHud())
  method text() = juego.mensaje()
  method textColor() = "FFD84AFF"
}

object cartelCarga {
  method position() = game.at(0 , 0)
  method image() = "Port_OvniUp.png"
}

object cartel {
  method position() {
    if (juego.estaEnMenu()) {
    return game.at(1, 1)
  } else if (juego.estaPerdido()) {
    return game.at(1, 1)
  } else if (juego.estaGanado()) {
    return game.at(1, 1)
  } else if (juego.nivelActual().numero() == 2) {
    return game.at(2, 6)
  } else if (juego.nivelActual().numero() == 3) {
    return game.at(2, 6)
  } else {
    return game.at(1, 1)
    }
  }

  method image() {
    if (juego.estaEnMenu()) {
      return "Inicio.png"
    } else if (juego.estaPerdido()) {
      return "gameover.png"
    } else if (juego.estaGanado()) {
      return "victoria.png"
    } else if (juego.nivelActual().numero() == 2) {
      return "nivel2.png"
    } else  {
      return "nivel3.png"
    }
  }
}