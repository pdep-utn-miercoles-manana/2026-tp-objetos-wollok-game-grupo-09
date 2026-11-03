import wollok.game.*

object tablero {
  const property ancho = 12
  const property alto = 16

  method filaPiso() = 0
  method filaMeta() = alto - 2
  method filaHud() = alto - 1
  method columnaCentral() = ancho.div(2)

  method posicionInicial() = game.at(self.columnaCentral(), 4)

  // area de juego
  method posicionValida(posicion) = game.at(
    posicion.x().max(0).min(ancho - 1),
    posicion.y().max(self.filaPiso()).min(self.filaMeta())
  )

  method posicionAlAzarArriba() = game.at(0.randomUpTo(ancho).truncate(0), self.filaMeta())

  method llegoAlPiso(posicion) = posicion.y() <= self.filaPiso()
  method llegoALaMeta(posicion) = posicion.y() >= self.filaMeta()

  // se fue por la derecha o bajó hasta el piso
  method salioDelAreaDeJuego(posicion) = posicion.x() >= ancho || posicion.y() <= self.filaPiso()

  // a unas casillas al azar del borde izquierdo: tarda un rato en volver a entrar
  method posicionAlAzarIzquierda() = game.at(
    (-12).randomUpTo(-2).truncate(0),
    (self.filaPiso() + 1).randomUpTo(self.filaMeta()).truncate(0)
  )
}

object arriba        { method siguiente(posicion) = posicion.up(1) }
object izquierda     { method siguiente(posicion) = posicion.left(1) }
object derecha       { method siguiente(posicion) = posicion.right(1) }
object diagonalAbajo { method siguiente(posicion) = posicion.right(1).down(1) }
