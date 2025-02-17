if !has("python3")
  echo "vim-jwt-decode need vim to be compiled with +python3"
  finish
endif

if exists('g:vim_luhn_validate_plugin_loaded')
  finish
endif

nmap <silent><leader>luhn :LuhnValidate<CR>

python3 << EOF
import vim

def _luhn_algorithm(digits: str):
    def calculate_sum(payload: str, sum=0, multiplier=2):
        if len(payload) == 0: return sum

        head = int(payload[:1])
        tail = payload[1:]

        result = head * multiplier
        if result > 9: result -= 9

        return calculate_sum(payload=tail, sum=sum+result, multiplier=2 if multiplier == 1 else 1)

    checkdigit = int(digits[-1])
    payload = digits[:-1][::-1] # drop last, reverse

    sum = calculate_sum(payload)
    newcheckdigit = (10 - (sum % 10)) % 10

    if checkdigit == newcheckdigit:
        print('valid payload')
    else:
        print('invalid payload')


def luhn_validate():
    row, col = vim.current.window.cursor
    current_line = vim.current.buffer[row-1]

    if not current_line:
        print('Nothing to validate!')
        return

    try:
        _luhn_algorithm(current_line)
    except Exception as e:
        print('Failed to validate payload! (%s)' % (e.msg))
        return
EOF

function! LuhnValidate()
    python3 luhn_validate()
endfunction

command! -nargs=0 LuhnValidate call LuhnValidate()

let g:vim_luhn_validate_plugin_loaded = 1
