#include <stdio.h>
#include <string.h>
#include <stdlib.h>

const int maxy = 200;
const int maxx = 150;

const char  *pd = ">v<^";

char *m;

int Y, X, dir, sx;

char g[maxy][maxx+2];
char M[6000];
/*
  50 150
 100 100
  50 50
   1 0
   1 5626
*/

void pp()
{
  char c[10];
  for (int y = 0; y < maxy; y++) {
    for (int x = 0; x < maxx; x++) {
      if (Y==y&&X==x) {
        snprintf(c, 10, "[7m%c[m", pd[dir]);
      } else {
        c[0] = g[y][x];
        c[1] = 0;
      }
      printf("%s", c);
    }
    printf("%s\n", (Y==y) ? "*************" : "");
  }
  printf("\n");
}

int getdist()
{
   int v,n;
   sscanf(m, "%d%n", &v, &n);
   m += n;
   return v;
}
int getdir()
{
   if (*m == 'L') {
     m++;
     return -1;
   } else if (*m == 'R') {
     m++;
     return 1;
   } else {
     printf("getdir: unexpected char %s\n", m);
   }
}

int main(int argc,char *argv[])
{
  FILE *fd = fopen(argv[1], "r");
  int line = 0;
  int len = maxx+2;
  char *p = &g[0][0];
  while (fgets(p,len,fd) != NULL) {
    // puts(p);
    if (p[0]=='\n') {
      fgets(M,6000,fd);
      char *p = strchr(M, '\n');
      *p = 0;
      fclose(fd);
      break;
    }
    char *pp = strchr(p, '\n');
    char *pe = &g[line][maxx+1];
    while (pp < pe) *pp++ = ' '; // space fill to end
    if (line == 0) {
      pp = strchr(p, '.');
      X = sx = pp - p;
      //printf("sx = %d, check |%4.4s|\n", sx, &p[sx-1]);
    }
    p = &g[++line][0];
  }
  printf("maxx %d maxy %d line %d\n", maxx, maxy, line);

  Y = 0;
  m = M;
  while (strlen(m) > 0) {
    int dist = getdist();
    if (strlen(m) < 4) { printf("Move %d %c @ %d %d %s\n", dist, pd[dir], Y, X, m); }
#if 1
    for (int i = 0; i < dist; i++) {
      int nX = X;
      int nY = Y;
      if (dir == 0) nX = X + 1;
      else if (dir == 2) nX = X - 1;
      else if (dir == 1) nY = Y + 1;
      else if (dir == 3) nY = Y - 1;
      int wrap = 0;
      if (nY < 0 || nY >= maxy || nX < 0 || nX >= maxx) { wrap = 1; }
      if (wrap == 0 && g[nY][nX] == '#') break; // blocked
      if (wrap == 0 && g[nY][nX] == '.') { X = nX; Y = nY; } // good
      else { // need to wrap
        if (dir == 0) { // wrap to left
          for (nX = X; nX >= 0 && g[nY][nX] != ' '; nX--);
          nX++; // overshot
          if (g[nY][nX] == '#') break; // must stay at Y,X
          else if (g[nY][nX] == '.') { X = nX; Y = nY; }
          else printf("WLunexpected value %c @ %d,%d\n", g[nY][nX], nY, nX);
        } else if (dir == 2) { // wrap to right
          for (nX = X; nX < maxx && g[nY][nX] != ' '; nX++);
          nX--; // # overshot
          if (g[nY][nX] == '#') break;
          else if (g[nY][nX] == '.') { X = nX; Y = nY; }
          else printf("WRunexpected value %c @ %d,%d\n", g[nY][nX], nY, nX);
        } else if (dir == 1) { // wrap up
          for (nY = Y; nY >= 0 && g[nY][nX] != ' '; nY--);
          nY++; // overshot
          if (g[nY][nX] == '#') break;
          else if (g[nY][nX] == '.') { X = nX; Y = nY; }
          else printf("WUunexpected value %c @ %d,%d\n", g[nY][nX], nY, nX);
        } else { // wrap down
          for (nY = Y; nY < maxy && g[nY][nX] != ' '; nY++);
          nY--; //  overshot
          if (g[nY][nX] == '#') break;
          else if (g[nY][nX] == '.') { X = nX; Y = nY; }
          else printf("WDunexpected value %c @ %d,%d\n", g[nY][nX], nY, nX);
        }
      }
    }
#endif
    if (strlen(m) > 0) {
      dir += getdir();
      if (dir < 0) dir=3;
      if (dir > 3) dir=0;
    }
    printf("%d %d\n", Y, X);
    //printf("%d %d dist %d dir %d remain %d %s\n", Y, X, dist, dir, strlen(m), m);
  }
  printf("Y %d X %d %d %c\n", Y, X, dir, pd[dir]);
  printf("%d\n", 1000 * (Y+1) + 4 * (X+1) + dir);
}
