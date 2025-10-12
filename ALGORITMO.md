# 🧮 Informações Técnicas sobre o Algoritmo

## Problema de Corte de Estoque (Cutting Stock Problem)

O otimizador utiliza uma variante 2D do problema clássico de corte de estoque, que é um problema de otimização combinatória NP-difícil. Isso significa que encontrar a solução ótima perfeita pode ser computacionalmente inviável para grandes conjuntos de dados.

## Algoritmo Guillotine Bin Packing

### Por que Guillotine?

O nome "Guillotine" vem do fato de que todos os cortes são retos (ortogonais) e atravessam completamente de uma borda a outra do material, similar ao funcionamento de uma guilhotina. Isso é perfeito para marcenaria porque:

1. **Compatibilidade com máquinas**: Serra circular, esquadrejadeira e serra de painel fazem cortes retos
2. **Facilidade de execução**: Cortes mais simples de realizar na prática
3. **Segurança**: Cortes retos são mais seguros e precisos
4. **Eficiência**: Menos movimentação da peça durante o corte

### Como Funciona

1. **Ordenação**: Peças são ordenadas por área (maior para menor)
   - Heurística: peças maiores são mais difíceis de alocar

2. **Alocação**: Para cada peça:
   - Procura o melhor retângulo livre disponível
   - Usa critério "Best Short Side Fit" (melhor encaixe pelo lado menor)
   - Tenta sem rotação e com rotação (se permitido)

3. **Divisão do Espaço**: Após colocar uma peça:
   - O espaço restante é dividido em novos retângulos livres
   - Retângulos contidos em outros são removidos (pruning)

4. **Margem de Corte**: Automaticamente adiciona a espessura da serra
   - Evita que peças fiquem coladas
   - Simula o material perdido no corte

### Complexidade

- **Tempo**: O(n²) onde n é o número de peças
- **Espaço**: O(m) onde m é o número de retângulos livres

## Heurísticas Utilizadas

### Best Short Side Fit (BSSF)

Para cada peça, escolhe o retângulo livre onde o lado menor da peça melhor se encaixa no lado menor do retângulo.

**Vantagens:**
- Minimiza desperdício em uma dimensão
- Bom equilíbrio entre qualidade e velocidade
- Funciona bem com peças de tamanhos variados

### First Fit Decreasing (FFD)

As peças são processadas em ordem decrescente de área.

**Vantagens:**
- Peças grandes são alocadas primeiro
- Peças pequenas preenchem espaços restantes
- Evita situação onde peças grandes não cabem no final

## Eficiência Típica

Baseado em testes com projetos reais de marcenaria:

- **Peças similares**: 75-85% de aproveitamento
- **Peças variadas**: 65-75% de aproveitamento
- **Peças muito pequenas**: 80-90% de aproveitamento
- **Peças muito grandes**: 50-65% de aproveitamento

## Limitações

1. **Solução Aproximada**: Não garante a solução ótima
2. **Cortes Guilhotina**: Todos os cortes devem ser retos e completos
3. **Sem Aninhamento**: Não há encaixe de formas complexas
4. **2D Simples**: Não considera textura ou orientação do material

## Melhorias Futuras Possíveis

### 1. Algoritmos Alternativos

- **Maximal Rectangles**: Mantém todos os retângulos máximos possíveis
- **Skyline**: Otimizado para peças de larguras variadas
- **Genetic Algorithm**: Busca por soluções quase-ótimas

### 2. Otimizações

- **Look-ahead**: Considera próximas peças antes de decidir
- **Backtracking limitado**: Tenta alternativas quando há desperdício alto
- **Multi-start**: Executa múltiplas vezes com diferentes ordenações

### 3. Recursos Avançados

- **Veio da madeira**: Respeitar direção das fibras
- **Fita de borda**: Considerar bordas que precisam de acabamento
- **Agrupamento**: Manter peças similares juntas
- **Priorização**: Peças críticas têm prioridade de alocação

### 4. Visualização

- **Instruções de corte passo-a-passo**: Sequência numerada
- **Medidas anotadas**: Dimensões em cada peça no SVG
- **Impressão otimizada**: Layout pronto para levar para oficina
- **3D**: Visualização tridimensional do projeto completo

## Comparação com Métodos Comerciais

Software comercial como **Corte Certo**, **OptiCut**, **CutList Optimizer**:

- Usam algoritmos mais sofisticados (branch-and-bound, programação dinâmica)
- Consideram mais restrições (borda, textura, prioridade)
- Interface gráfica mais elaborada
- Podem ser 5-10% mais eficientes em aproveitamento

**Este software**:
- Open source e gratuito
- Bom suficiente para a maioria dos projetos
- Fácil de customizar
- Educacional - código visível e documentado

## Referências

1. Lodi, A., Martello, S., & Vigo, D. (2002). "Recent advances on two-dimensional bin packing problems"
2. Jylänki, J. (2010). "A Thousand Ways to Pack the Bin - A Practical Approach to Two-Dimensional Rectangle Bin Packing"
3. Burke, E. K., Kendall, G., & Whitwell, G. (2004). "A New Placement Heuristic for the Orthogonal Stock-Cutting Problem"

## Contribuindo com Melhorias

Se você é desenvolvedor e quer melhorar o algoritmo:

1. Experimente com diferentes heurísticas de ordenação
2. Implemente algoritmos alternativos (Maximal Rectangles, Skyline)
3. Adicione look-ahead para melhor decisão
4. Implemente multi-threading para testar múltiplas configurações
5. Adicione métricas e benchmarks

Pull requests são bem-vindos!


