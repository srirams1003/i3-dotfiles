- Go over the Gemini conversations and your diary entries THOROUGHLY to touch on all the points of confusion I've had over these projects and why certain fixes were necessary to fix bugs i encountered such as the autoreload preload enable bug.

- Also go over all the concepts in these projects I am supposed to know like PWM, SPI, etc.

- Understand how the .ioc file works
    - When I change something in main.c, does the corresponding .ioc file get modified directly upon building the project? How come I can clone the repo from a remote origin and all the peripherals and components on the Nucleo board are set correctly as per the current project's requirements? Is this because of git tracking the .ioc file or is there something more powerful going on underneath?

- For each project, turn it into a separate subdirectory in a main electronics portfolio repo. Each subdirectory corresponding to a project should have a README file explaining the main concepts in it, how to set it up in STM32CubeIDE, all the needed components, and how to wire all the hardware together.
    - can I use a IDE agent like Cursor or Gemini to do this? Make it generate everything based on my current working code for each project. Then I can go in later for human verification by trying to set everything up again solely by following the instructions from each project's README.
