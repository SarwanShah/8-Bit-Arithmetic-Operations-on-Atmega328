# 8-bit Arithmetic Operations on ATMEGA328  

## 📌 Project Overview  
This project was developed under the **EE375 Microcontrollers and Interfacing** course at Habib University during Fall 2018
This project demonstrates **8-bit arithmetic operations** on a sequence of **10 value pairs**, where the operations (`+`, `-`, `*`, `/`) are defined using **ASCII characters**. The data and operations are stored in the **ATMEGA328 Program Flash Memory (ROM)** at address `0x200`. The computed results are then stored in the **Internal RAM (IRAM)** at address `0x100`.  

**REPORT: https://github.com/SarwanShah/8-Bit-Arithmetic-Operations-on-Atmega328/blob/main/Report.pdf**

## 🛠 Features  
- ✅ **Data Storage in ROM** (Sequential organization of values & operators)  
- ✅ **Efficient Data Extraction** (Using **Z Pointer** for ROM access)  
- ✅ **Arithmetic Computation** (Addition, Subtraction, Multiplication, Division)  
- ✅ **Data Storage in IRAM** (Using **X Pointer** for result storage)  
- ✅ **Pointer Incrementation Logic** (Dynamic memory addressing for sequential operations)  

## 📌 Data Organization  
### ➤ **Stored Data Format in ROM**  
| Address Range | Data Type | Example Value |
|--------------|-----------|--------------|
| `0x200 - 0x209` | **First Operand (DATA1)** | `96, 70, 47, 30, 42, 30, 10, 48, 100, 47` |
| `0x20A - 0x213` | **Operation (DATA2 in ASCII)** | `'+', '-', '+', '-', '*', '/', '+', '-', '*', '/'` |
| `0x214 - 0x21D` | **Second Operand (DATA3)** | `3, 4, 7, 9, 2, 3, 1, 1, 10, 0` |

## 🏗 Project Implementation  
### ➤ **Data Extraction from ROM**  
- The **Z Pointer** is used to extract the corresponding values and operator at each step.  
- Since **AVR ROM stores data in 2-byte chunks**, the address stored in `Z` is **bit-shifted left** to access the actual data.  

### ➤ **Arithmetic Operations**  
- **Addition, Subtraction, and Multiplication** use AVR built-in arithmetic instructions.  
- **Division is implemented using repeated subtraction** until the remainder is zero.  
- If the divisor is **zero**, the result is automatically set to **zero** to prevent errors.  

### ➤ **Data Storage in IRAM**  
- The **X Pointer** is used to store computed results in RAM at `0x100`.  
- **Multiplication results** (which may be **16-bit values**) are stored in **two consecutive memory locations**.  
- **Pointer incrementation logic** (`incrementerX` and `incrementerZ`) ensures sequential memory allocation for each result.  

## 🔧 Components & Registers Used  
| Component/Register | Description |
|--------------------|------------|
| **ATMEGA328** | Microcontroller used for computation |
| **Z Pointer** | Accesses sequential values from ROM |
| **X Pointer** | Stores results in IRAM |
| **General Purpose Registers (GPRs)** | Hold intermediate values during computation |
| **r17** | Stores intermediate results for arithmetic operations |
| **r0 & r1** | Store 16-bit multiplication results |

## ⚠ Design Challenges  
- **ROM Addressing Complexity:** Since AVR ROM uses **word-addressing**, a shift operation was required when using the **Z pointer** to correctly access 8-bit values.  
- **Efficient Division Implementation:** Since AVR lacks direct division instructions, **repeated subtraction logic** was used instead.  
- **Handling 16-bit Multiplication Results:** Multiplication could produce values exceeding **8-bit storage**, requiring special storage logic in IRAM.  

## 📌 Conclusion  
This project showcases **low-level memory manipulation and arithmetic computation** using the ATMEGA328 microcontroller. The approach leverages **pointer-based data extraction, efficient arithmetic execution, and optimized memory storage techniques**.  
