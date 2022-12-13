#######################################
#
# OKO 05.09.2020 Dijkstra's algorithm
#     13.09.2020 Polished for presenting it on GitHub
#
#######################################
BEGIN {
	INFINITE = 999999 #every thinkable weight should not exceed this number
	HALT = interpretOptionsAndArguments(); # evaluate command line args
	if (HALT) {
		showHelp();
		exit;
	}
	showInputParams();
}

# skip comment rows
/^#/ { next }

# Read in edge definitions to build up a directed or undirected weighted graph.
# Implementation is with 'adjacency lists' by means of an array.
{
	V[$1] = 1 # vertex set
	V[$2] = 1
	G[$1][$2] = $3 # graph
	if (dir == "U")
		G[$2][$1] = $3 # an undirected graph has an additional edge the other way around
}

END {
	if (HALT) exit; #otherwise END part would be executed despite exit in BEGIN part!
	
	dijkstra(G, V, u, t); # execute algorithm
}

#---------------------------------------------------------------
# Calculates vector L, that expresses the shortest path lengths from u to all other vertices.
# G - graph
# V - vertex set
# u - starting vertex
# t - ending vertex; maybe empty
#---------------------------------------------------------------
function dijkstra(G, V, u, t) {
	calcAll = (t == "") # Shortest path lengths to all vertices or only to t?  
	initL(u, G, V) # L is working array for shortest path length of all vertices
	T[u] = 1 # working vertex set
	delete V[u]
	
	while (length(V) > 0) {
		v_ = findVertexWithMinimalWeight(V, T, L)
		
		if (isFinished(v_, t, calcAll)) # further abortion condition!
			break;
		
		T[v_] = 1
		delete V[v_]
		
		adjustL(v_, L, V, T, G)
	}
	showResult(L, calcAll)
}

#--------------------------------------------------------------
# Initialise solution vector L.
# u - starting vertex
# G - graph
# V - vertex set
#---------------------------------------------------------------
function initL(u, G, V) {
	for (v in V) {
		if (u == v) {
			L[v] = 0;
		} else if (isEdge(u, v, G)) {
			L[v] = G[u][v]
		} else {
			L[v] = INFINITE
		}
	}
}

#---------------------------------------------------------------
# Can we jump out the main loop of the algorithmn?
# v_ - 'minimal' vertex in the sense of the algorithm
# t - ending vertex; maybe empty
# calcAll - true if t is empty; false otherwise
#---------------------------------------------------------------
function isFinished(v_, t, calcAll) {
	return (v_ == "" || (!calcAll && v_ == t))
}

#--------------------------------------------------------------
# Returns v so that L(v) is minimal.
# V - set of unvisited vertices
# T - working vertex set
# L - solution vector
#---------------------------------------------------------------
function findVertexWithMinimalWeight(V, T, L) {
	min = INFINITE
	minVertex = "" #otherwise, if var is not set in loop, the value of the last invocation of this func will be returned!
	
	for (v in V) {
		if (L[v] < min) {
			minVertex = v;
			min = L[v]				
		}
	}
	
	return minVertex
}

#--------------------------------------------------------------
# Adjusts L, that, if we go via v_, the shortest length will be possibly decreased.
# v_ - 'minimal' vertex in the sense of the algorithm
# L - solution vector
# V - set of unvisited vertices
# T - working vertex set
# G - graph
#---------------------------------------------------------------
function adjustL(v_, L, V, T, G) {
	for (v in V) {
		if (isEdge(v_, v, G) && L[v] > L[v_] + G[v_][v]) {
			L[v] = L[v_] + G[v_][v];
		}
	}
}

#--------------------------------------------------------------
# Is (v, w) an edge of graph G?
# v, w - vertices
# G - graph
#---------------------------------------------------------------
function isEdge(v, w, G) {
	return (v in G) && (w in G[v]) 
}

#---------------------------------------------------------------
# L - solution vector
# calcAll - true if no ending vertex; false otherwise
#---------------------------------------------------------------
function showResult(L, calcAll) {
	print "----- RESULT -----"
	if (calcAll)
		for (v in L) print "L(" v ")=" L[v]
	else
		print "L(" t ")=" L[t]
}

#---------------------------------------------------------------
# Interpret command line options and arguments.
#---------------------------------------------------------------
function interpretOptionsAndArguments() {
	if (ARGV[1] == "help" || ARGV[1] == "" || u == "")
		return 1;
	if (dir == "")
		dir = "U";
	if (dir !~ /[DU]/)
		return 1;
	return 0;
}

function showHelp() {
	print ""
	print "PURPOSE: Calculates shortest path lengths according to Dijkstra\47s algorithm."
	print ""
	print "USAGE:   awk -v u=<start> [-v t=<end>] [-v dir=<direction>] -f dijkstra.awk <file>"
	print "         awk -f dijkstra.awk help"
	print ""
	print "         file       input file containing graph specification, i.e. definition of edges"
	print "         start      label of starting vertex"
	print "         end        label of ending vertex; if not given, the shortest lengths for ALL vertices are calculated"
	print "         direction  U|D (default U); file defines an Undirected or Directed graph"
	print ""
	print "EXAMPLE: awk -v u=a -v t=g -v dir=D -f dijkstra.awk graphdef.txt"
	print ""
	print "         starting (ending) vertex is \"a\"(\"g\"), file \"graphdef.txt\" specifies a directed graph"
	print ""
}

function showInputParams() {
	print "----- INPUT PARAMETERS -----"
	print "file: " ARGV[1]
	print "direction type: " (dir=="U"?"undirected":"directed")
	print "starting vertex: " u
	print "ending vertex: " (t==""?"(not specified) - calculation for all vertices":t)
}
