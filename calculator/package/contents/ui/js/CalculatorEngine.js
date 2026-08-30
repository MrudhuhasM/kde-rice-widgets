.pragma library

/**
 * Deterministic Shunting-Yard Calculator Engine
 * Clean, safe parser without eval() or dynamic code execution.
 */

function formatResult(value, precision) {
    if (typeof value !== "number" || isNaN(value) || !isFinite(value)) {
        return "ERROR";
    }

    let p = precision || 10;
    // Round to precision to strip IEEE-754 floating point artifacts
    let rounded = parseFloat(value.toPrecision(p));
    
    // Handle small integer/float conversions
    if (Math.abs(rounded) < 1e-12 && Math.abs(rounded) > 0) {
        return rounded.toExponential(4);
    }
    
    let str = rounded.toString();
    return str;
}

function tokenize(input) {
    let tokens = [];
    let i = 0;
    let len = input.length;

    while (i < len) {
        let ch = input[i];

        // Skip whitespace
        if (/\s/.test(ch)) {
            i++;
            continue;
        }

        // Numbers (integers and decimals)
        if (/[0-9]/.test(ch) || (ch === '.' && i + 1 < len && /[0-9]/.test(input[i + 1]))) {
            let numStr = "";
            let hasDot = false;

            while (i < len && (/[0-9]/.test(input[i]) || input[i] === '.')) {
                if (input[i] === '.') {
                    if (hasDot) break;
                    hasDot = true;
                }
                numStr += input[i];
                i++;
            }

            tokens.push({ type: "NUMBER", value: parseFloat(numStr) });
            continue;
        }

        // Normalizing operators
        if (ch === '×' || ch === '*') {
            tokens.push({ type: "OP", value: "*" });
            i++;
            continue;
        }
        if (ch === '÷' || ch === '/') {
            tokens.push({ type: "OP", value: "/" });
            i++;
            continue;
        }
        if (ch === '+') {
            // Check if unary plus
            let prev = tokens[tokens.length - 1];
            if (!prev || prev.type === "OP" || (prev.type === "PAREN" && prev.value === "(") || prev.type === "UNARY") {
                // Unary plus can simply be skipped
                i++;
                continue;
            }
            tokens.push({ type: "OP", value: "+" });
            i++;
            continue;
        }
        if (ch === '-' || ch === '−') {
            // Check if unary minus
            let prev = tokens[tokens.length - 1];
            if (!prev || prev.type === "OP" || (prev.type === "PAREN" && prev.value === "(") || prev.type === "UNARY") {
                tokens.push({ type: "UNARY", value: "neg" });
            } else {
                tokens.push({ type: "OP", value: "-" });
            }
            i++;
            continue;
        }
        if (ch === '%') {
            tokens.push({ type: "POSTFIX", value: "%" });
            i++;
            continue;
        }
        if (ch === '(' || ch === ')') {
            tokens.push({ type: "PAREN", value: ch });
            i++;
            continue;
        }

        // Unrecognized character
        return { ok: false, error: "INVALID CHARACTER: " + ch };
    }

    return { ok: true, tokens: tokens };
}

function shuntingYard(tokens) {
    let output = [];
    let stack = [];

    const precedence = {
        "+": 1,
        "-": 1,
        "*": 2,
        "/": 2,
        "neg": 3,
        "%": 4
    };

    const isRightAssociative = {
        "neg": true
    };

    for (let i = 0; i < tokens.length; i++) {
        let token = tokens[i];

        if (token.type === "NUMBER") {
            output.push(token);
        } else if (token.type === "POSTFIX") {
            output.push(token);
        } else if (token.type === "UNARY") {
            stack.push(token);
        } else if (token.type === "OP") {
            let op1 = token.value;
            while (stack.length > 0) {
                let top = stack[stack.length - 1];
                if (top.type === "PAREN" && top.value === "(") {
                    break;
                }
                let op2 = top.value;
                let prec1 = precedence[op1] || 0;
                let prec2 = precedence[op2] || 0;

                if ((!isRightAssociative[op1] && prec1 <= prec2) ||
                    (isRightAssociative[op1] && prec1 < prec2)) {
                    output.push(stack.pop());
                } else {
                    break;
                }
            }
            stack.push(token);
        } else if (token.type === "PAREN") {
            if (token.value === "(") {
                stack.push(token);
            } else if (token.value === ")") {
                let foundOpen = false;
                while (stack.length > 0) {
                    let top = stack.pop();
                    if (top.type === "PAREN" && top.value === "(") {
                        foundOpen = true;
                        break;
                    }
                    output.push(top);
                }
                if (!foundOpen) {
                    return { ok: false, error: "UNMATCHED PARENTHESES" };
                }
            }
        }
    }

    while (stack.length > 0) {
        let top = stack.pop();
        if (top.type === "PAREN") {
            return { ok: false, error: "UNMATCHED PARENTHESES" };
        }
        output.push(top);
    }

    return { ok: true, rpn: output };
}

function evaluateRPN(rpn, precision) {
    let stack = [];

    for (let i = 0; i < rpn.length; i++) {
        let token = rpn[i];

        if (token.type === "NUMBER") {
            stack.push(token.value);
        } else if (token.type === "UNARY" && token.value === "neg") {
            if (stack.length < 1) {
                return { ok: false, error: "INVALID EXPRESSION" };
            }
            let a = stack.pop();
            stack.push(-a);
        } else if (token.type === "POSTFIX" && token.value === "%") {
            if (stack.length < 1) {
                return { ok: false, error: "INVALID EXPRESSION" };
            }
            let a = stack.pop();
            stack.push(a / 100);
        } else if (token.type === "OP") {
            if (stack.length < 2) {
                return { ok: false, error: "INVALID EXPRESSION" };
            }
            let b = stack.pop();
            let a = stack.pop();
            let res = 0;

            switch (token.value) {
                case "+":
                    res = a + b;
                    break;
                case "-":
                    res = a - b;
                    break;
                case "*":
                    res = a * b;
                    break;
                case "/":
                    if (b === 0) {
                        return { ok: false, error: "DIVISION BY ZERO" };
                    }
                    res = a / b;
                    break;
                default:
                    return { ok: false, error: "UNKNOWN OPERATOR" };
            }

            stack.push(res);
        }
    }

    if (stack.length !== 1) {
        return { ok: false, error: "INVALID EXPRESSION" };
    }

    let finalValue = stack[0];
    if (isNaN(finalValue) || !isFinite(finalValue)) {
        return { ok: false, error: "NUMERIC ERROR" };
    }

    return {
        ok: true,
        numericValue: finalValue,
        result: formatResult(finalValue, precision)
    };
}

function evaluate(expression, precision) {
    if (!expression || expression.trim() === "") {
        return { ok: true, numericValue: 0, result: "0" };
    }

    let tokenResult = tokenize(expression);
    if (!tokenResult.ok) {
        return tokenResult;
    }

    if (tokenResult.tokens.length === 0) {
        return { ok: true, numericValue: 0, result: "0" };
    }

    let shuntingResult = shuntingYard(tokenResult.tokens);
    if (!shuntingResult.ok) {
        return shuntingResult;
    }

    return evaluateRPN(shuntingResult.rpn, precision);
}
