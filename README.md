# CythRay
An example program that combines the [Cyth](https://github.com/vldr/Cyth) programming language with Raylib, allowing direct access to Raylib functions from a Cyth script file.

Note: This project is incomplete. Some Raylib functions are missing or only partially implemented; this is intended purely as an example.

<img src="splash.png" style="width:500px;">

# Building

To build CythRay, you will need to have [CMake](https://cmake.org/) and gcc/clang/MSVC installed. 

### Linux

Run the following commands from the root directory (in a terminal):

```bash
mkdir build
cd build
cmake ..
make
```

### MacOS

Run the following commands from the root directory (in a terminal):

_Xcode project_:  
```
mkdir build
cd build
cmake -G Xcode ..
```

Then, in the `build` directory, open `cythray.xcodeproj` in Xcode.

_Makefile_:  
```bash
mkdir build
cd build
cmake ..
make
```

### Windows

Run the following commands from the root directory (in a terminal):

_Visual Studio 2022 project_:  
```
cmake.exe -S . -B build -G "Visual Studio 17 2022"
```

_Visual Studio 2026 project_:  
```
cmake.exe -S . -B build -G "Visual Studio 18 2026"
```

Then, in the `build` directory, open `cythray.sln` / `cythray.slnx` in Visual Studio.
