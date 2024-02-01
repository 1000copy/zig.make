const std = @import("std");

pub fn build(b: *std.Build) !void {
    var sources = std.ArrayList([]const u8).init(b.allocator);
    // std.debug.print("{s}", .{a[0]});

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zmake",
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.addIncludePath(std.build.LazyPath.relative("."));
    exe.addIncludePath(std.build.LazyPath.relative("./src/"));

    exe.addIncludePath(std.build.LazyPath.relative("./lib/"));
    exe.defineCMacro("HAVE_CONFIG_H", null);
    if (exe.target.isWindows()) {
        exe.addIncludePath(std.build.LazyPath.relative("./src/w32/include/"));

        exe.defineCMacro("_CONSOLE", null);
        exe.defineCMacro("WINDOWS32", null);
        const aa = .{ "ar", "arscan", "commands", "default", "dir", "expand", "file", "function", "getopt", "getopt1", "guile", "hash", "implicit", "job", "load", "loadapi", "main", "misc", "output", "read", "remake", "remote-stub", "rule", "shuffle", "signame", "strcache", "variable", "version", "vpath" };
        const cc = .{ "pathstuff", "w32os", "compat/posixfcn", "subproc/misc", "subproc/sub_proc", "subproc/w32err" };
        const bb = .{ "fnmatch", "glob", "getloadavg" };
        inline for (cc) |c| {
            try sources.append("src/w32/" ++ c ++ ".c");
        }
        inline for (aa) |c| {
            try sources.append("src/" ++ c ++ ".c");
        }
        inline for (bb) |c| {
            try sources.append("lib/" ++ c ++ ".c");
        }
    }
    if (exe.target.isDarwin()) {
        exe.defineCMacro("STDC_HEADERS", null);
        exe.defineCMacro("__STDC__", null); //
        // exe.defineCMacro("ENABLE_NLS", null);
        exe.defineCMacro("LIBDIR", "\".\"");
        exe.defineCMacro("LOCALEDIR", "\"/usr/local/share/locale\"");
        exe.defineCMacro("__GNU_LIBRARY__", null);
        const bbmac = .{
            "concat-filename",
            "findprog-in",
            "fnmatch",
            "glob",
        };
        const aamac = .{ "ar", "arscan", "commands", "default", "dir", "expand", "file", "function", "getopt", "getopt1", "guile", "hash", "implicit", "job", "load", "loadapi", "main", "misc", "output", "read", "remake", "rule", "shuffle", "signame", "strcache", "variable", "version", "vpath", "posixos", "remote-stub" };

        inline for (aamac) |c| {
            try sources.append("src/" ++ c ++ ".c");
        }
        inline for (bbmac) |c| {
            try sources.append("lib/" ++ c ++ ".c");
        }
    }
    exe.addCSourceFiles(sources.items, &.{"-Wstring-compare"});
    exe.linkLibC();
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
// -Doptimize=ReleaseSmall
// 1.1M vs. 218K
// 首先需要build.sh ,它会生成一些必要的文件，比如glob.h ,其他定义了c文件引用的macro，然后在zig build就可以了。
