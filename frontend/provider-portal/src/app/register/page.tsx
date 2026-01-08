"use client";

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { ArrowRight, Building2, MapPin, User, Mail, Lock, Loader2, CheckCircle } from 'lucide-react';
import Link from 'next/link';

export default function Register() {
    const router = useRouter();
    const [formData, setFormData] = useState({
        name: '',
        address: '',
        admin_name: '',
        admin_email: '',
        admin_password: '',
    });
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError('');

        try {
            const response = await fetch('https://api-gateway-1070962557424.us-central1.run.app/auth/register-org', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.detail || 'Registration failed');
            }

            setSuccess(true);
            setTimeout(() => {
                router.push('/doctor/dashboard'); // Redirect to dashboard after success
            }, 2000);

        } catch (err: any) {
            setError(err.message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-[#F5F5F7] text-[#1D1D1F] font-sans selection:bg-[#0071E3] selection:text-white flex flex-col">

            {/* Navigation */}
            <nav className="fixed top-0 left-0 right-0 z-50 px-6 py-4 glass transition-all duration-300">
                <div className="max-w-7xl mx-auto flex items-center justify-between">
                    <Link href="/" className="flex items-center space-x-2">
                        <div className="w-8 h-8 bg-black rounded-lg flex items-center justify-center text-white font-bold text-lg">M</div>
                        <span className="text-xl font-semibold tracking-tight">MedX</span>
                    </Link>
                    <div className="flex items-center space-x-4">
                        <span className="text-sm text-[#86868B]">Already registered?</span>
                        <Link
                            href="/doctor/dashboard"
                            className="text-sm font-medium text-[#0071E3] hover:underline"
                        >
                            Sign in
                        </Link>
                    </div>
                </div>
            </nav>

            <div className="flex-grow flex items-center justify-center px-4 pt-24 pb-12">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.8, ease: "easeOut" }}
                    className="w-full max-w-2xl"
                >
                    <div className="text-center mb-10">
                        <h1 className="text-3xl md:text-4xl font-bold mb-3 tracking-tight text-[#1D1D1F]">Register Organization</h1>
                        <p className="text-[#86868B] text-lg">Join the network of modern healthcare providers.</p>
                    </div>

                    <div className="bg-white rounded-[2rem] shadow-xl shadow-black/5 p-8 md:p-12 border border-[#D2D2D7]/30 backdrop-blur-xl">

                        {success ? (
                            <div className="flex flex-col items-center justify-center py-12 text-center space-y-4">
                                <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mb-4">
                                    <CheckCircle className="w-10 h-10 text-green-600" />
                                </div>
                                <h2 className="text-2xl font-bold text-[#1D1D1F]">Registration Successful!</h2>
                                <p className="text-[#86868B]">Redirecting you to the dashboard...</p>
                            </div>
                        ) : (
                            <form onSubmit={handleSubmit} className="space-y-8">

                                {error && (
                                    <div className="p-4 bg-red-50 text-red-600 text-sm rounded-xl flex items-center mb-6">
                                        <span className="mr-2">⚠️</span> {error}
                                    </div>
                                )}

                                {/* Organization Details */}
                                <div className="space-y-6">
                                    <h3 className="text-xs font-semibold text-[#86868B] uppercase tracking-wider mb-4 border-b border-[#E5E5EA] pb-2">Organization Details</h3>

                                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        <div className="space-y-2">
                                            <label className="text-[13px] font-medium text-[#1D1D1F] ml-1">Hospital Name</label>
                                            <div className="relative group">
                                                <Building2 className="absolute left-4 top-1/2 -translate-y-1/2 text-[#86868B] w-5 h-5 transition-colors group-focus-within:text-[#0071E3]" />
                                                <input
                                                    type="text"
                                                    required
                                                    className="w-full bg-[#F5F5F7] border-0 text-[#1D1D1F] rounded-xl py-3.5 pl-12 pr-4 focus:ring-2 focus:ring-[#0071E3]/20 focus:bg-white transition-all outline-none font-medium placeholder:text-[#86868B]/50"
                                                    placeholder="e.g. Sinai Health Center"
                                                    value={formData.name}
                                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                                />
                                            </div>
                                        </div>

                                        <div className="space-y-2">
                                            <label className="text-[13px] font-medium text-[#1D1D1F] ml-1">Location / Address</label>
                                            <div className="relative group">
                                                <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-[#86868B] w-5 h-5 transition-colors group-focus-within:text-[#0071E3]" />
                                                <input
                                                    type="text"
                                                    required
                                                    className="w-full bg-[#F5F5F7] border-0 text-[#1D1D1F] rounded-xl py-3.5 pl-12 pr-4 focus:ring-2 focus:ring-[#0071E3]/20 focus:bg-white transition-all outline-none font-medium placeholder:text-[#86868B]/50"
                                                    placeholder="e.g. 1 Infinite Loop"
                                                    value={formData.address}
                                                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* Admin Details */}
                                <div className="space-y-6">
                                    <h3 className="text-xs font-semibold text-[#86868B] uppercase tracking-wider mb-4 border-b border-[#E5E5EA] pb-2">Administrator Access</h3>

                                    <div className="space-y-6">
                                        <div className="space-y-2">
                                            <label className="text-[13px] font-medium text-[#1D1D1F] ml-1">Full Name</label>
                                            <div className="relative group">
                                                <User className="absolute left-4 top-1/2 -translate-y-1/2 text-[#86868B] w-5 h-5 transition-colors group-focus-within:text-[#0071E3]" />
                                                <input
                                                    type="text"
                                                    required
                                                    className="w-full bg-[#F5F5F7] border-0 text-[#1D1D1F] rounded-xl py-3.5 pl-12 pr-4 focus:ring-2 focus:ring-[#0071E3]/20 focus:bg-white transition-all outline-none font-medium placeholder:text-[#86868B]/50"
                                                    placeholder="John Appleseed"
                                                    value={formData.admin_name}
                                                    onChange={(e) => setFormData({ ...formData, admin_name: e.target.value })}
                                                />
                                            </div>
                                        </div>

                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <div className="space-y-2">
                                                <label className="text-[13px] font-medium text-[#1D1D1F] ml-1">Email Address</label>
                                                <div className="relative group">
                                                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-[#86868B] w-5 h-5 transition-colors group-focus-within:text-[#0071E3]" />
                                                    <input
                                                        type="email"
                                                        required
                                                        className="w-full bg-[#F5F5F7] border-0 text-[#1D1D1F] rounded-xl py-3.5 pl-12 pr-4 focus:ring-2 focus:ring-[#0071E3]/20 focus:bg-white transition-all outline-none font-medium placeholder:text-[#86868B]/50"
                                                        placeholder="admin@hospital.com"
                                                        value={formData.admin_email}
                                                        onChange={(e) => setFormData({ ...formData, admin_email: e.target.value })}
                                                    />
                                                </div>
                                            </div>

                                            <div className="space-y-2">
                                                <label className="text-[13px] font-medium text-[#1D1D1F] ml-1">Password</label>
                                                <div className="relative group">
                                                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-[#86868B] w-5 h-5 transition-colors group-focus-within:text-[#0071E3]" />
                                                    <input
                                                        type="password"
                                                        required
                                                        className="w-full bg-[#F5F5F7] border-0 text-[#1D1D1F] rounded-xl py-3.5 pl-12 pr-4 focus:ring-2 focus:ring-[#0071E3]/20 focus:bg-white transition-all outline-none font-medium placeholder:text-[#86868B]/50"
                                                        placeholder="••••••••"
                                                        value={formData.admin_password}
                                                        onChange={(e) => setFormData({ ...formData, admin_password: e.target.value })}
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-4">
                                    <button
                                        type="submit"
                                        disabled={isLoading}
                                        className="w-full bg-[#0071E3] hover:bg-[#0077ED] text-white font-medium text-lg py-4 rounded-full transition-all transform active:scale-[0.98] shadow-lg shadow-blue-500/25 flex items-center justify-center disabled:opacity-70 disabled:cursor-not-allowed"
                                    >
                                        {isLoading ? (
                                            <Loader2 className="w-6 h-6 animate-spin" />
                                        ) : (
                                            <>
                                                <span>Create Organization ID</span>
                                                <ArrowRight className="w-5 h-5 ml-2" />
                                            </>
                                        )}
                                    </button>
                                    <p className="text-center text-xs text-[#86868B] mt-6">
                                        By registering, you agree to our <a href="#" className="underline hover:text-[#1D1D1F]">Terms of Service</a> and <a href="#" className="underline hover:text-[#1D1D1F]">Privacy Policy</a>.
                                    </p>
                                </div>
                            </form>
                        )}
                    </div>
                </motion.div>
            </div>
        </div>
    );
}
