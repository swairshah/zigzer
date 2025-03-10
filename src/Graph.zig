const std = @import("std");
const Allocator = std.mem.Allocator;

const Graph = @This();

// Internal structure to represent edges
const Edge = struct {
    to: usize,
    weight: f32,
};

// Graph fields
allocator: Allocator,
adjacency_lists: std.ArrayList(std.ArrayList(Edge)),
vertex_count: usize,

// Initialize a new graph with a given number of vertices
pub fn init(allocator: Allocator, vertex_count: usize) !Graph {
    var adj_lists = try std.ArrayList(std.ArrayList(Edge)).initCapacity(allocator, vertex_count);

    // Initialize empty adjacency lists for each vertex
    for (0..vertex_count) |_| {
        try adj_lists.append(std.ArrayList(Edge).init(allocator));
    }

    return Graph{
        .allocator = allocator,
        .adjacency_lists = adj_lists,
        .vertex_count = vertex_count,
    };
}

// Clean up all allocated memory
pub fn deinit(self: *Graph) void {
    for (self.adjacency_lists.items) |*list| {
        list.deinit();
    }
    self.adjacency_lists.deinit();
}

// Add a directed edge from vertex 'from' to vertex 'to' with given weight
pub fn addEdge(self: *Graph, from: usize, to: usize, weight: f32) !void {
    if (from >= self.vertex_count or to >= self.vertex_count) {
        return error.VertexOutOfBounds;
    }

    try self.adjacency_lists.items[from].append(.{
        .to = to,
        .weight = weight,
    });
}

pub fn addBidirectionalEdge(self: *Graph, from: usize, to: usize, weight: f32) !void {
    // We need 'try' because addEdge() returns an error union - it can fail with
    // error.VertexOutOfBounds if the vertices are invalid. The 'try' keyword
    // allows us to handle errors gracefully.
    try self.addEdge(from, to, weight);
    try self.addEdge(to, from, weight);
}

// Get all neighbors of a vertex
pub fn getNeighbors(self: *const Graph, vertex: usize) ![]const Edge {
    if (vertex >= self.vertex_count) {
        return error.VertexOutOfBounds;
    }

    return self.adjacency_lists.items[vertex].items;
}
