[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]



<br />
<p align="center">
  <h3 align="center">BlueLib</h3>

  <p align="center">
    Useful helpers for Bluespec developers.
    <br />
    <a href="https://github.com/esa-tu-darmstadt/BlueLib/wiki"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/esa-tu-darmstadt/BlueLib/issues">Report Bug</a>
    ·
    <a href="https://github.com/esa-tu-darmstadt/BlueLib/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)



<!-- ABOUT THE PROJECT -->
## About The Project

Over the years developing in Bluespec we came accross certain features missing from the AzureIP library. This repository contains some of the frequently used parts.

  * A FIFO that counts the maximum number of entries. Useful for design space exploration.
  * Network helper functions, e.g. toggle endianess in Word.
  * Send out data over a AXI4 stream based network interface, e.g. Xilinx 10G Ethernet Subsystem
  * Parse ethernet packets coming from such a subsystem
  * Produce colorful text for testbenches



### Built With

* [Bluespec Compiler](https://github.com/B-Lang-org/bsc)


## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Have the bluespec compiler installed.

### Installation

1. Clone the repo
```sh
git clone github.com/esa-tu-darmstadt/BlueLib.git
```
2. Optional: Install [`BlueAXI`](https://github.com/esa-tu-darmstadt/BlueAXI) for `PacketParser` or `PacketSender`
3. Import `BlueLib` or a part of the packet in your Bluespec packet:
```
import BlueLib :: *;
```
4. Add the `src` directory to your `bsc` library path during compilation:
```sh
bsc ${OTHER_FLAGS} -p path/to/BlueLib/src
```


## Usage

```bluespec
printColorTimed(RED, $format("Hello World!"));
```
![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) `(0) Hello World!`

_For more examples, please refer to the [Documentation](https://github.com/esa-tu-darmstadt/BlueLib/wiki)_



<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/esa-tu-darmstadt/BlueLib/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Embedded Systems and Applications Group - https://www.esa.informatik.tu-darmstadt.de

Project Link: [https://github.com/esa-tu-darmstadt/BlueLib](https://github.com/esa-tu-darmstadt/BlueLib)


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[issues-shield]: https://img.shields.io/github/issues/esa-tu-darmstadt/BlueLib.svg?style=flat-square
[issues-url]: https://github.com/esa-tu-darmstadt/BlueLib/issues
[license-shield]: https://img.shields.io/github/license/esa-tu-darmstadt/BlueLib.svg?style=flat-square
[license-url]: https://github.com/esa-tu-darmstadt/BlueLib/blob/master/LICENSE