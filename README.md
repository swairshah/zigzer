# Implemeting stuff in Zig. 

Working on a low level macos lib in zig. Trying to figure out the langauge with simpler implementations. 

## Understanding `@This()` Pattern 

In Zig, `@This()` is a built-in function used for single-type file organization, somewhat analogous to Python classes but with clear distinctions in how type members are declared:

- When you write `const MyType = @This();` in a file, you're declaring that this file defines a struct named `MyType`.
- Fields declared with direct type annotations (like `my_field: u32`) become instance variables (similar to Python's `self.my_field`).
- Types declared with `const` (like `const SubType = struct {...}`) become associated types (similar to nested classes in Python).
- Functions declared with `pub fn` become methods associated with the type.

Example comparison:
```python
class Graph:
    class Edge:  # Nested class
        def __init__(self, to, weight):
            self.to = to
            self.weight = weight
    
    def __init__(self):
        self.vertex_count = 0  # Instance variable
```

```zig
// Zig equivalent using @This()
const Graph = @This();

const Edge = struct {  // Associated type
    to: usize,
    weight: f32,
};

vertex_count: usize,  // Instance field


```

## Understanding Type Polymorphism in Zig

Zig offers several patterns for handling multiple related types. Let's explore them using graph implementations as an example:

### 1. Using `anytype`

The simplest approach uses Zig's `anytype` for compile-time type checking:

```zig
fn printGraph(graph: anytype) !void {
    switch (@TypeOf(graph)) {
        Graph => {
            // Handle Graph type
        },
        UndirectedGraph => {
            // Handle UndirectedGraph type
        },
        else => @compileError("Unsupported graph type"),
    }
}
```

Pros:
- Simple to implement
- No extra boilerplate
- Good for small number of types

Cons:
- Less explicit about supported types
- Error messages appear at the switch statement
- Harder for IDE tooling

### 2. Using Interfaces (VTable Pattern)

A more structured approach using Zig's interface pattern:

```zig
const GraphInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    const VTable = struct {
        printFn: *const fn(ptr: *anyopaque) void,
    };
};
```

Each graph type implements the interface:

```zig
const Graph = struct {
    pub fn toInterface(self: *Graph) GraphInterface {
        return .{
            .ptr = self,
            .vtable = &.{
                .printFn = printImpl,
            },
        };
    }
};
```

Pros:
- Explicit contract between types
- Better for multiple implementations
- Clear error messages
- Better IDE/LSP support

Cons:
- More boilerplate
- Requires explicit conversion with toInterface()
- More complex for simple cases

### 3. Composition Pattern

Another approach is to implement UndirectedGraph as a wrapper around Graph:

```zig
const UndirectedGraph = struct {
    graph: Graph,
    
    pub fn init(allocator: std.mem.Allocator, vertex_count: usize) !UndirectedGraph {
        return .{
            .graph = try Graph.init(allocator, vertex_count),
        };
    }

    pub fn addEdge(self: *UndirectedGraph, from: usize, to: usize, weight: f32) !void {
        try self.graph.addEdge(from, to, weight);
        try self.graph.addEdge(to, from, weight);  // Add reverse edge
    }
};
```

With this pattern, printing becomes simpler because UndirectedGraph can delegate to Graph:

```zig
fn printGraph(graph: *Graph) void {
    // Implementation that works for Graph
}

// UndirectedGraph just forwards to the inner graph
const undirected = try UndirectedGraph.init(allocator, 4);
printGraph(&undirected.graph);
```

Pros:
- Reuses existing Graph functionality
- Clear relationship between types
- No need for interfaces or type switching
- Easy to extend Graph functionality

Cons:
- Less flexibility if UndirectedGraph needs very different behavior
- May expose implementation details
- Might need to wrap many methods

### Choosing the Right Pattern

1. Use `anytype` when:
   - You have few types
   - Types are known at compile time
   - Simple functionality is needed

2. Use interfaces when:
   - You need runtime polymorphism
   - Many different implementations exist
   - Types need to be stored in collections

3. Use composition when:
   - New type is an extension of base type
   - Most functionality can be delegated
   - Clear "is-a" relationship exists
