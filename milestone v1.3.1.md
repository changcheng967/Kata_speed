Milestone: v1.3.1 Release
Description:
This milestone focuses on enhancing the Go AI engine with several key improvements, making it more accessible and powerful. Key goals include strengthening the bot, providing a pre-built Kata benchmark, simplifying the installation process, expanding platform support, and improving model loading times.

Due Date:
[2024-06-30]

Issues and Pull Requests:
v1.3.1 Enhancements:
Stronger Bot:

Upgrade the bot's capabilities to handle higher visit rates per second, improving performance and responsiveness.
Pre-built Kata Benchmark:

Provide a pre-built Kata benchmark for users who do not know C++. This will allow them to evaluate the AI engine without needing to build from source.
Installation Process Improvements:

Create a Windows installation wizard or a simplified CMD installation process to make the setup easier for non-technical users.
Create b40 and b30 Private Network Support:

Develop and integrate support for private networks b40 and b30.
Create at Least 3 New Networks:

Develop and integrate new networks: b18, b60, and b28.
v1.3.2 rc-2 Features:
Add b30 Models:
Integrate and support the new b30 models designed for low to medium complexity tasks with balanced performance.
v1.3.3 rc-1 Features:
Platform Support Expansion:

Add support for MacOS and Linux, ensuring the AI engine is accessible to a wider range of users.
Create Support for CUDA 12.5 (if possible):

Investigate and add support for CUDA 12.5 to leverage the latest GPU acceleration improvements.
Bug Fix:
TensorRT 8.5.2 Support Fix:
Fix issues related to support for TensorRT 8.5.2 as noted in the origin Kata 1.4.1 release, ensuring compatibility and stability.
Major Change:
Engine Name Change:
Change the engine name to "kata_speed" to better reflect the new capabilities and performance improvements.
Performance Improvements:
Shorter Model and Benchmark Loading, Tuning Time:
Optimize the model and benchmark loading and tuning time to mitigate the increased duration caused by TensorRT integration.
Notes:
Ensure all documentation is updated to reflect these changes, including new installation guides for Windows, MacOS, and Linux.
Provide detailed release notes and instructions for each pre-release and final release to guide users through the new features and fixes.
