import 'dart:math';
import '../../../models/floor_plan_model.dart';

class RoutingEngine {
  /// Calculates the safest path from a start node to the nearest safe exit.
  /// This implements a modified Dijkstra's/A* algorithm where nodes marked
  /// as 'unsafeZones' or 'blockedPaths' are heavily penalized or ignored.
  List<GraphNode> calculateSafestPath({
    required String startNodeId,
    required FloorPlanModel floorPlan,
  }) {
    // Basic validation
    if (floorPlan.pathfindingNodes.isEmpty) return [];

    // Map for O(1) lookups
    final nodeMap = {for (var node in floorPlan.pathfindingNodes) node.id: node};
    
    if (!nodeMap.containsKey(startNodeId)) return [];

    // Priority queue equivalent (using a simple sorted list for MVP)
    final openSet = <String>{startNodeId};
    final cameFrom = <String, String>{};
    
    // Cost from start to node
    final gScore = <String, double>{startNodeId: 0.0};

    while (openSet.isNotEmpty) {
      // Find node in openSet with lowest gScore
      String currentId = openSet.reduce((a, b) => (gScore[a] ?? double.infinity) < (gScore[b] ?? double.infinity) ? a : b);
      GraphNode current = nodeMap[currentId]!;

      // If we reached an exit, reconstruct the path
      if (current.isExit || current.isStairwell) {
        return _reconstructPath(cameFrom, currentId, nodeMap);
      }

      openSet.remove(currentId);

      for (String neighborId in current.connectedNodeIds) {
        if (!nodeMap.containsKey(neighborId)) continue;
        GraphNode neighbor = nodeMap[neighborId]!;

        // 1. Avoid Elevator lock logic during emergencies (unless explicitly allowed)
        if (neighbor.isElevator) continue;

        // 2. Penalize or block danger zones
        if (floorPlan.blockedPaths.contains(neighborId)) continue;
        
        // Calculate distance
        double dist = sqrt(pow(current.x - neighbor.x, 2) + pow(current.y - neighbor.y, 2));
        
        // If it's an unsafe zone (smoke/fire), we heavily penalize it to force the algorithm
        // to find a longer, safer path if one exists.
        double penalty = floorPlan.unsafeZones.contains(neighborId) ? 10000.0 : 0.0;
        
        double tentativeGScore = (gScore[currentId] ?? double.infinity) + dist + penalty;

        if (tentativeGScore < (gScore[neighborId] ?? double.infinity)) {
          cameFrom[neighborId] = currentId;
          gScore[neighborId] = tentativeGScore;
          if (!openSet.contains(neighborId)) {
            openSet.add(neighborId);
          }
        }
      }
    }

    // No path found
    return [];
  }

  List<GraphNode> _reconstructPath(Map<String, String> cameFrom, String currentId, Map<String, GraphNode> nodeMap) {
    final path = <GraphNode>[nodeMap[currentId]!];
    while (cameFrom.containsKey(currentId)) {
      currentId = cameFrom[currentId]!;
      path.insert(0, nodeMap[currentId]!);
    }
    return path;
  }
}
