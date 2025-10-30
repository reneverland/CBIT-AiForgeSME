/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  darkMode: 'class', // 启用深色模式
  theme: {
    extend: {
      colors: {
        // 主色调 - 紫色系
        primary: '#7C3AED',
        secondary: '#A855F7',
        // CUHK 经管学院配色
        cuhk: {
          purple: '#7C3AED', // 主紫色
          gold: '#F39C12',   // 金色点缀
          dark: '#6D28D9',   // 深紫色
          light: '#A855F7',  // 浅紫色
        },
        // ChatGPT 风格配色
        gpt: {
          light: {
            bg: '#FFFFFF',
            'bg-alt': '#F7F7F8',
            text: '#343541',
            'text-secondary': '#6B7280',
            border: '#E5E7EB',
          },
          dark: {
            bg: '#343541',
            'bg-alt': '#444654',
            text: '#ECECF1',
            'text-secondary': '#C5C5D2',
            border: '#4D4D4D',
          }
        }
      },
      borderRadius: {
        'button': '8px',
      },
      fontFamily: {
        'pacifico': ['Pacifico', 'cursive'],
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
        'slide-up': 'slideUp 0.3s ease-out',
        'slide-in': 'slideIn 0.3s ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideIn: {
          '0%': { transform: 'translateX(-10px)', opacity: '0' },
          '100%': { transform: 'translateX(0)', opacity: '1' },
        }
      }
    },
  },
  plugins: [],
}

