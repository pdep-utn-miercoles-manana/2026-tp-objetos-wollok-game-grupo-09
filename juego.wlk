import wollok.game.*
import tablero.*
import jugador.*
import obstaculos.*

class Nivel {
  const property numero
  const property msEntreApariciones   // cada cuánto aparece un obstáculo
  const property msDeCaida            // cada cuánto bajan una casilla
  const fabricas                      // qué obstáculos pueden aparecer (repetir = más probable)
  const property fondo                // imagen de fondo: cuanto más alto el nivel, más lejos se llega

  method nuevoObstaculo() = fabricas.anyOne().crear(tablero.posicionAlAzarArriba())
}

object juego {
  const msGravedad = 1500
  const eventos = ["aparecer", "caer", "gravedad"]

  const niveles = [
    new Nivel(numero = 1, msEntreApariciones = 900, msDeCaida = 450,
              fabricas = [rocas, rocas, rocas, globos, escudos],
              fondo = "fondo_cielo.png"),
    new Nivel(numero = 2, msEntreApariciones = 700, msDeCaida = 350,
              fabricas = [rocas, rocas, rocas, nubes, nubes, globos, escudos],
              fondo = "fondo_estrellas.png"),
    new Nivel(numero = 3, msEntreApariciones = 500, msDeCaida = 250,
              fabricas = [rocas, rocas, yunques, yunques, nubes, nubes, globos, escudos],
              fondo = "fondo_galaxia.png")
  ]

  var property nivelActual = niveles.first()
  const property obstaculos = []
  const peligrosDelPiso = []
  var property enCurso = false
  var property mensaje = ""
  var estado = "menu"
  var cartelVisible = false

  method estaEnMenu() = estado == "menu"
  method estaPerdido() = estado == "perdido"
  method estaGanado() = estado == "ganado"

  // ---------------- Configuración ----------------
  method configurar() {
    game.title("Ovni UP")
    game.width(tablero.ancho())
    game.height(tablero.alto())
    game.cellSize(40)
    self.cambiarANivel(niveles.first())
    game.addVisual(jugador)
    game.addVisual(hud)
    self.configurarTeclas()
    self.mostrarCartel()
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
    jugador.reaparecer()
    mensaje = ""
    estado = "jugando"
    enCurso = true
    game.onTick(nivelActual.msEntreApariciones(), "aparecer", { self.agregarObstaculo(nivelActual.nuevoObstaculo()) })
    game.onTick(nivelActual.msDeCaida(), "caer", { obstaculos.copy().forEach({ obstaculo => obstaculo.caer() }) })
    game.onTick(msGravedad, "gravedad", { jugador.caer() })
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
      game.schedule(1500, { self.iniciarNivel() })
    }
  }

  method perder(motivo) {
    self.pausar()
    estado = "perdido"
    self.terminar(motivo)
    self.mostrarCartel()
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

object hud {
  method position() = game.at(tablero.columnaCentral(), tablero.filaHud())
  method text() = "Nivel " + juego.nivelActual().numero() + "   Vidas: " + jugador.vidas() + "   " + juego.mensaje()
  method textColor() = "FFFFFFFF"
}

object cartel {
  method position() = game.at(1, 1)
  method image() {
    if (juego.estaEnMenu()) {
      return "Inicio.png"
    } else if (juego.estaPerdido()) {
      return "gameover.png"
    } else {
      return "victoria.png"
    }
  }
}