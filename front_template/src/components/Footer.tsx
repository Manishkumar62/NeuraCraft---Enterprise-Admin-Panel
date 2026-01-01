const Footer = () => {
    const currentYear = new Date().getFullYear();

    return (
        <footer className="bg-white border-t border-gray-200 px-6 py-3 flex-shrink-0">
            <div className="flex items-center justify-between text-sm text-gray-500">
                <div>
                    <span>© {currentYear} </span>
                    <span className="font-medium text-gray-700">Manishkumar Vishwakarma</span>
                    <span>. All rights reserved.</span>
                </div>

                <div className="flex items-center gap-4">
                    <span>Version 1.0.0</span>
                    <span className="text-gray-300">|</span>
                    <a
                        href="#"
                        className="hover:text-blue-600 transition-colors"
                    >
                        Documentation
                    </a>
                    <span className="text-gray-300">|</span>

                    <a href="#"
                        className="hover:text-blue-600 transition-colors"
                    >
                        Support
                    </a>
                </div>
            </div>
        </footer>
    );
};

export default Footer;