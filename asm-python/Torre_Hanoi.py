#Recursão que traduz a lógica do jogo
def torre_hanoi(n, origem, destino, auxiliar):
    if n == 1:
        #Caso base da recursão
        print(f"Mova o disco 1 de {origem} para {destino}.")
        return
        #Lógica de recursão para os casos onde a quantidade de discos (n) é maior do que 1
    torre_hanoi(n-1, origem, auxiliar, destino)
    print(f"Mova o disco {n} de {origem} para {destino}.")
    torre_hanoi(n-1, auxiliar, destino, origem)

#Recebendo a entrada (quantidade de discos)
n = int(input())
#Aplicando a recursão e atribuindo valores às variáveis
torre_hanoi(n, "A", "C", "B")