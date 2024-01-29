const std = @import("std");

pub fn build(b: *std.Build) !void {
    var sources = std.ArrayList([]const u8).init(b.allocator);
    // std.debug.print("{s}", .{a[0]});
    const aa = .{ "ar", "arscan", "commands", "default", "dir", "expand", "file", "function", "getopt", "getopt1", "guile", "hash", "implicit", "job", "load", "loadapi", "main", "misc", "output", "read", "remake", "remote-stub", "rule", "shuffle", "signame", "strcache", "variable", "version", "vpath" };
    const cc = .{ "pathstuff", "w32os", "compat/posixfcn", "subproc/misc", "subproc/sub_proc", "subproc/w32err" };
    const bb = .{ "fnmatch", "glob", "getloadavg" };
    // const aaaa = aa ++ bb ++ cc;
    // if (exe.target.isWindows()) {}

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zmake",
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    // WINDOWS32
    exe.addIncludePath(std.build.LazyPath.relative("."));
    exe.addIncludePath(std.build.LazyPath.relative("./src/"));
    exe.addIncludePath(std.build.LazyPath.relative("./src/w32/include/"));
    exe.addIncludePath(std.build.LazyPath.relative("./lib/"));

    // exe.defineCMacro("__MINGW32__", null);
    exe.defineCMacro("_CONSOLE", null);
    exe.defineCMacro("HAVE_CONFIG_H", null);
    exe.defineCMacro("WINDOWS32", null);
    exe.defineCMacro("STDC_HEADERS", null);
    inline for (aa) |c| {
        try sources.append("src/" ++ c ++ ".c");
    }
    inline for (bb) |c| {
        try sources.append("lib/" ++ c ++ ".c");
    }
    if (exe.target.isWindows()) {
        inline for (cc) |c| {
            try sources.append("src/w32/" ++ c ++ ".c");
        }
    }
    exe.addCSourceFiles(sources.items, &.{});
    exe.linkLibC();
    //exe.addIncludePath(std.build.LazyPath.relative("bass/linux"));
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
