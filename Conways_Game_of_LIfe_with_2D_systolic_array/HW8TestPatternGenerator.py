# EE119B Conway's Game of Life
# Pattern & Testvector generator
#
# Activate or Deactivate the comments(#'s) to select a pattern and generate its next patterns throughout NUM_EPOCHS epochs
# You can observe how the cellular automata changes over the next NUM_EPOCHS epochs
# Remember to use the correct MESH_SIZE for each of the patterns to acquire the correct test vectors
#
# 2018/03/11 Sung Hoon Choi     Created
# 2018/03/13 Sung Hoon Choi     Added more test cases
# 2018/03/14 Sung Hoon Choi     Updated comments

import numpy as np

# How many epochs do you want to test for each pattern?
NUM_EPOCHS = 6

########################## MESH_SIZE = 5 patterns ##########################
# MESH_SIZE = 5
# #Blinker (period: 2)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 1, 0, 0, 0],
#                  [0, 0, 0, 1, 0, 0, 0],
#                  [0, 0, 0, 1, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Stabilizes to Beehive (Stabilizes at 4th cycle)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 1, 1, 1, 0, 0],
#                  [0, 0, 1, 0, 0 ,0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Full Square
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 1, 1, 1, 1, 1, 0],
#                  [0, 1, 1, 1, 1, 1, 0],
#                  [0, 1, 1, 1, 1, 1, 0],
#                  [0, 1, 1, 1, 1, 1, 0],
#                  [0, 1, 1, 1, 1, 1, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Boat (Still lives)
# Mesh = np. array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 1, 1, 0, 0 ,0],
#                  [0, 0, 1, 0, 1, 0, 0],
#                  [0, 0, 0, 1, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Tub (Still lives)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0],
#                 [0, 0, 1, 0, 1, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0]])
#
# # Glider (Keeps moving)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 1, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0],
#                 [0, 1, 1, 1, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0]])

# # Death (Dies)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 1, 0, 0, 0, 0, 0],
#                  [0, 0, 1, 1, 1, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Random
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 1, 1, 1, 0, 0, 0],
#                  [0, 1, 1, 1, 1, 0, 0],
#                  [0, 1, 1, 1, 1, 0, 0],
#                  [0, 0, 1, 0, 0, 0, 0],
#                  [0, 0, 1, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

# # Corner and Edges
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0],
#                  [0, 1, 1, 0, 1, 1, 0],
#                  [0, 1, 0, 0, 0, 1, 0],
#                  [0, 1, 0, 0, 0, 0, 0],
#                  [0, 1, 0, 0, 0, 1, 0],
#                  [0, 1, 1, 0, 1, 1, 0],
#                  [0, 0, 0, 0, 0, 0, 0]])

########################## MESH_SIZE = 6 patterns ##########################
MESH_SIZE = 6
#
# # Glider (keeps moving)
Mesh = np. array([[0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 1, 0, 0, 0, 0, 0],
                  [0, 0, 0, 1, 0, 0, 0, 0],
                  [0, 1, 1, 1, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0],
                  [0, 0, 0, 0, 0, 0, 0, 0]])

# # Beacon (period: 2)
# Mesh = np. array([[0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 1, 1, 0, 0, 0, 0],
#                   [0, 0, 1, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 1, 0, 0],
#                   [0, 0, 0, 0, 1, 1, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0]])
#
#
# # Toad (period: 2)
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 1, 0, 0, 0],
#                  [0, 0, 1, 0, 0, 1, 0, 0],
#                  [0, 0, 1, 0, 0, 1, 0, 0],
#                  [0, 0, 0, 1, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0, 0],
#                  [0, 0, 0, 0, 0, 0, 0, 0]])
#
# # Loaf (Still lives)
# Mesh = np. array([[0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 1, 1, 0, 0, 0],
#                   [0, 0, 1, 0, 0, 1, 0, 0],
#                   [0, 0, 0, 1, 0, 1, 0, 0],
#                   [0, 0, 0, 0, 1, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0]])
#
# # Stabilizer (Stabilizes at third cycle)
# Mesh = np. array([[0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 1, 0, 0, 0, 0],
#                   [0, 0, 0, 1, 0, 0, 0, 0],
#                   [0, 0, 0, 1, 0, 0, 0, 0],
#                   [0, 0, 0, 1, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0],
#                   [0, 0, 0, 0, 0, 0, 0, 0]])

########################## MESH_SIZE = 12 pattern ##########################
# MESH_SIZE = 12
# #A heavyweight Spaceship in the middle and two Gliders on the corners
# Mesh = np.array([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
#                 [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
#                 [0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0],
#                 [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
#                 )


print(Mesh)
ResultMesh = np.zeros([MESH_SIZE+2,MESH_SIZE+2])
for epoch in range (1,NUM_EPOCHS+1):
    print("epoch %s ============================================" % epoch)
    for i in range (1,MESH_SIZE+1):
        for j in range (1, MESH_SIZE+1):
            if Mesh[i][j] == 1:
                if Mesh[i-1][j]+Mesh[i-1][j+1]+Mesh[i][j+1]+Mesh[i+1][j+1]+Mesh[i+1][j]+Mesh[i+1][j-1]+Mesh[i][j-1]+Mesh[i-1][j-1] == 2 or Mesh[i-1][j]+Mesh[i-1][j+1]+Mesh[i][j+1]+Mesh[i+1][j+1]+Mesh[i+1][j]+Mesh[i+1][j-1]+Mesh[i][j-1]+Mesh[i-1][j-1] == 3:
                    ResultMesh[i][j] = 1
                else:
                    ResultMesh[i][j] = 0
            else:
                if Mesh[i-1][j]+Mesh[i-1][j+1]+Mesh[i][j+1]+Mesh[i+1][j+1]+Mesh[i+1][j]+Mesh[i+1][j-1]+Mesh[i][j-1]+Mesh[i-1][j-1] == 3:
                    ResultMesh[i][j] = 1
                else:
                    ResultMesh[i][j] = 0
    print(ResultMesh)
    Mesh = ResultMesh
    ResultMesh = np.zeros([MESH_SIZE + 2, MESH_SIZE + 2])

    print("====================================================")



