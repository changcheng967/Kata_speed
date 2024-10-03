

# Kata_speed

Kata_speed is a Go AI engine that is designed to be fast, strong, and easy to run. It supports most GPU and CPU configurations, making it accessible to a wide range of users. It uses a well-trained private b20 network and is inspired by KataGo.



## OGS auto-account creator
https://github.com/changcheng967/Online-Go.com-Account-Generator
## OGS Active Game Rank Updater(Leela Zero Strong)
https://github.com/changcheng967/OGS-Active-Game-Rank-Updater

Press [here](https://github.com/changcheng967/OGS-Active-Game-Rank-Updater/blob/main/README.md) for instructions of using
## Key Features

- **Strong Performance**: Enhanced algorithms for better gameplay.
- **High Speed**: Optimized for quick decision-making.
- **Broad Compatibility**: Supports most GPU and CPU configurations.
- **Ease of Use**: Simple setup and configuration.
- **Well-Trained Private b20 Network**: Utilizes a powerful network for improved performance.

## Installation

### Cloning the Repository

To download Kata_speed by cloning the repository, follow these steps:

1. Open a terminal (cmd) and navigate to the directory where you want to clone the repository.
2. Run the following command to clone the repository:
   ```sh
   git clone https://github.com/changcheng967/Kata_speed.git
   ```
Downloading and Installing CMake GUI
If you don't have CMake GUI installed, download and install it from the CMake website.

Configuring with CMake GUI
Open CMake GUI.
Set the source code to the cpp folder in your cloned repository. For example:

```txt
C:\Users\<your_username>\Kata_speed\cpp
```
Set the binary directory to the folder where you want to save the executable file.
Click Configure and select your generator (e.g., Visual Studio, MinGW Makefiles, etc.).
Click Generate.
Building the Executable
Open a terminal (cmd).
Navigate to the binary directory you set in CMake GUI.
Run the following command to build the executable:
```sh
make
```
Setting Up gtp2ogs
Download gtp2ogs.
Configure gtp2ogs with the following command:

```sh
gtp2ogs --apikey <bots_api_key> --config <path_to_your_config.json5> -- <path_to_your_executable\kataspeed.exe>
```
Replace <bots_api_key> with your bot's API key.
Create a JSON5 config file following the guide in the gtp2ogs repository.
Replace <path_to_your_executable\kataspeed.exe> with the path to your kataspeed.exe file.
Solving Unsupported CUDA v12.4 Issue
If you are experiencing issues with CUDA v12.4 not being supported, you can use the provided batch script solve_cuda_issue.bat to resolve the issue. This script will uninstall CUDA v12.4 and install CUDA v11.4, then rebuild Kata_speed. The script is also available on the release page.

Instructions:
Customize Paths:
Replace \path\to\Kata_speed with the actual path to your Kata_speed repository.


Save the Script:
Save the above script as solve_cuda_issue.bat.


Run the Script:
Right-click on solve_cuda_issue.bat and select "Run as administrator".
This script automates the process of resolving the unsupported CUDA issue.


Network Sharing Site
Visit our network sharing site to download pre-trained networks and share your own.


Contributing
We welcome contributions from the community. If you would like to contribute, please contact changcheng6541@gmail.com with your GitHub username and email.


Please see our Code of Conduct before contributing.


License
Kata_speed is licensed under the MIT License.


Contact
If you have any questions or need assistance, feel free to reach out to changcheng6541@gmail.com.


Thank you for using Kata_speed and helping us improve our software!
