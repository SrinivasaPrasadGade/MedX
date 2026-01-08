"use client";

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    Calendar, Users, Clock, Settings, LogOut,
    ChevronRight, Search, Bell, Menu, X, Check,
    User as UserIcon, Mail, Phone, MapPin, Activity
} from 'lucide-react';
import Link from 'next/link';

// Mock Data
const PATIENTS = [
    { id: 1, name: "Alice Smith", age: 34, lastVisit: "Oct 15, 2024", condition: "Hypertension", status: "Stable", avatar: "AS" },
    { id: 2, name: "Bob Jones", age: 52, lastVisit: "Oct 20, 2024", condition: "Type 2 Diabetes", status: "Critical", avatar: "BJ" },
    { id: 3, name: "Carol White", age: 28, lastVisit: "Oct 22, 2024", condition: "Asthma", status: "Stable", avatar: "CW" },
    { id: 4, name: "David Chen", age: 45, lastVisit: "Oct 23, 2024", condition: "Migraine", status: "Review", avatar: "DC" },
];

const SCHEDULE = {
    Monday: { start: "09:00", end: "17:00", active: true },
    Tuesday: { start: "09:00", end: "17:00", active: true },
    Wednesday: { start: "09:00", end: "17:00", active: true },
    Thursday: { start: "09:00", end: "17:00", active: true },
    Friday: { start: "09:00", end: "13:00", active: true },
};

const DOCTOR_PROFILE = {
    name: "Dr. Sarah Connor",
    specialty: "Cardiologist",
    email: "sarah.connor@medx.health",
    phone: "+1 (555) 000-0000",
    location: "San Francisco General",
    id: "DOC-8842",
};

export default function DoctorDashboard() {
    const [activeTab, setActiveTab] = useState('overview');
    const [schedule, setSchedule] = useState(SCHEDULE);
    const [showProfile, setShowProfile] = useState(false);
    const [greeting, setGreeting] = useState('');

    useEffect(() => {
        const hour = new Date().getHours();
        if (hour < 12) setGreeting('Good morning');
        else if (hour < 18) setGreeting('Good afternoon');
        else setGreeting('Good evening');
    }, []);

    const sidebarItems = [
        { id: 'overview', label: 'Overview', icon: Activity },
        { id: 'schedule', label: 'Schedule', icon: Calendar },
        { id: 'patients', label: 'Patients', icon: Users },
        { id: 'availability', label: 'Availability', icon: Clock },
    ];

    return (
        <div className="min-h-screen bg-[#F5F5F7] text-[#1D1D1F] font-sans flex">

            {/* Sidebar */}
            <aside className="w-20 lg:w-64 bg-white/80 backdrop-blur-xl border-r border-[#D2D2D7]/30 fixed h-full z-20 transition-all duration-300">
                <div className="p-6 flex items-center justify-center lg:justify-start space-x-3 mb-6">
                    <div className="w-10 h-10 bg-black rounded-xl flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-black/10">M</div>
                    <span className="hidden lg:block text-xl font-bold tracking-tight">MedX</span>
                </div>

                <nav className="px-3 space-y-1">
                    {sidebarItems.map((item) => (
                        <button
                            key={item.id}
                            onClick={() => setActiveTab(item.id)}
                            className={`w-full flex items-center p-3 rounded-xl transition-all duration-200 group ${activeTab === item.id
                                    ? 'bg-[#0071E3] text-white shadow-md shadow-[#0071E3]/25'
                                    : 'text-[#86868B] hover:bg-[#F5F5F7] hover:text-[#1D1D1F]'
                                }`}
                        >
                            <item.icon className="w-6 h-6 lg:mr-3" strokeWidth={2} />
                            <span className="hidden lg:block font-medium">{item.label}</span>
                            {activeTab === item.id && (
                                <motion.div layoutId="activeTabIndicator" className="absolute left-0 w-1 h-8 bg-transparent rounded-r-full" />
                            )}
                        </button>
                    ))}
                </nav>

                <div className="absolute bottom-6 left-0 right-0 px-3">
                    <button className="w-full flex items-center justify-center lg:justify-start p-3 text-[#86868B] hover:text-[#FF3B30] transition-colors rounded-xl hover:bg-[#FF3B30]/10">
                        <LogOut className="w-6 h-6 lg:mr-3" />
                        <span className="hidden lg:block font-medium">Sign Out</span>
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 ml-20 lg:ml-64 p-8 lg:p-12 transition-all duration-300">

                {/* Header */}
                <header className="flex justify-between items-center mb-12">
                    <div>
                        <h1 className="text-3xl lg:text-4xl font-bold tracking-tight text-[#1D1D1F]">
                            {greeting}, <br className="md:hidden" />
                            <span className="text-[#86868B]">{DOCTOR_PROFILE.name.split(' ')[1]}</span>
                        </h1>
                        <p className="text-[#86868B] mt-1">Here's what's happening today.</p>
                    </div>

                    <div className="flex items-center space-x-6">
                        <button className="relative p-2 text-[#86868B] hover:text-[#1D1D1F] transition-colors bg-white rounded-full shadow-sm border border-[#D2D2D7]/30">
                            <Bell className="w-5 h-5" />
                            <span className="absolute top-0 right-0 w-2.5 h-2.5 bg-[#FF3B30] rounded-full border-2 border-white"></span>
                        </button>

                        <div className="relative">
                            <button
                                onClick={() => setShowProfile(!showProfile)}
                                className="flex items-center space-x-3 focus:outline-none"
                            >
                                <div className="text-right hidden md:block">
                                    <p className="text-sm font-semibold text-[#1D1D1F]">{DOCTOR_PROFILE.name}</p>
                                    <p className="text-xs text-[#86868B]">{DOCTOR_PROFILE.specialty}</p>
                                </div>
                                <div className="w-12 h-12 bg-[#0071E3]/10 text-[#0071E3] rounded-full flex items-center justify-center font-bold text-lg border-2 border-white shadow-sm transition-transform hover:scale-105">
                                    SC
                                </div>
                            </button>

                            {/* Profile Dropdown */}
                            <AnimatePresence>
                                {showProfile && (
                                    <motion.div
                                        initial={{ opacity: 0, y: 10, scale: 0.95 }}
                                        animate={{ opacity: 1, y: 0, scale: 1 }}
                                        exit={{ opacity: 0, y: 10, scale: 0.95 }}
                                        className="absolute right-0 mt-4 w-80 bg-white rounded-2xl shadow-xl shadow-black/10 border border-[#D2D2D7]/50 p-6 z-50 origin-top-right glass"
                                    >
                                        <div className="flex flex-col items-center mb-6">
                                            <div className="w-20 h-20 bg-[#F5F5F7] rounded-full flex items-center justify-center mb-4 text-3xl font-bold text-[#86868B]">
                                                SC
                                            </div>
                                            <h3 className="text-xl font-bold text-[#1D1D1F]">{DOCTOR_PROFILE.name}</h3>
                                            <span className="bg-[#0071E3]/10 text-[#0071E3] px-3 py-1 rounded-full text-xs font-semibold mt-2">{DOCTOR_PROFILE.specialty}</span>
                                        </div>

                                        <div className="space-y-4">
                                            <div className="flex items-center p-3 bg-[#F5F5F7] rounded-xl">
                                                <Mail className="w-5 h-5 text-[#86868B] mr-3" />
                                                <div className="flex-1 overflow-hidden">
                                                    <p className="text-xs text-[#86868B] uppercase font-semibold">Email</p>
                                                    <p className="text-sm font-medium text-[#1D1D1F] truncate">{DOCTOR_PROFILE.email}</p>
                                                </div>
                                            </div>
                                            <div className="flex items-center p-3 bg-[#F5F5F7] rounded-xl">
                                                <Phone className="w-5 h-5 text-[#86868B] mr-3" />
                                                <div className="flex-1">
                                                    <p className="text-xs text-[#86868B] uppercase font-semibold">Phone</p>
                                                    <p className="text-sm font-medium text-[#1D1D1F]">{DOCTOR_PROFILE.phone}</p>
                                                </div>
                                            </div>
                                            <div className="flex items-center p-3 bg-[#F5F5F7] rounded-xl">
                                                <MapPin className="w-5 h-5 text-[#86868B] mr-3" />
                                                <div className="flex-1">
                                                    <p className="text-xs text-[#86868B] uppercase font-semibold">Location</p>
                                                    <p className="text-sm font-medium text-[#1D1D1F]">{DOCTOR_PROFILE.location}</p>
                                                </div>
                                            </div>
                                        </div>

                                        <button className="w-full mt-6 bg-[#1D1D1F] text-white py-3 rounded-xl font-medium hover:bg-black transition-colors">
                                            Edit Profile
                                        </button>
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    </div>
                </header>

                {/* Content Area */}
                <motion.div
                    key={activeTab}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ duration: 0.4 }}
                >
                    {activeTab === 'overview' && (
                        <div className="space-y-8">
                            {/* Stats Cards */}
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                {[
                                    { label: 'Total Patients', value: '1,234', change: '+12%', color: 'text-[#0071E3]' },
                                    { label: 'Appointments Today', value: '8', change: 'On Track', color: 'text-[#34C759]' },
                                    { label: 'Pending Reviews', value: '5', change: 'Action Needed', color: 'text-[#FF9500]' }
                                ].map((stat, i) => (
                                    <div key={i} className="bg-white p-6 rounded-3xl shadow-sm border border-[#D2D2D7]/30 flex flex-col justify-between h-32 hover:shadow-md transition-shadow">
                                        <span className="text-[#86868B] font-medium">{stat.label}</span>
                                        <div className="flex items-end justify-between">
                                            <span className="text-4xl font-bold tracking-tight text-[#1D1D1F]">{stat.value}</span>
                                            <span className={`text-sm font-semibold ${stat.color} bg-opacity-10 px-2 py-1 rounded-lg`}>{stat.change}</span>
                                        </div>
                                    </div>
                                ))}
                            </div>

                            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                                <div className="lg:col-span-2 bg-white rounded-[2rem] shadow-sm border border-[#D2D2D7]/30 p-8">
                                    <div className="flex justify-between items-center mb-6">
                                        <h2 className="text-2xl font-bold text-[#1D1D1F]">Upcoming Appointments</h2>
                                        <Link href="#" className="text-[#0071E3] font-medium hover:underline">See all</Link>
                                    </div>
                                    <div className="space-y-4">
                                        {[1, 2].map((i) => (
                                            <div key={i} className="flex items-center p-4 hover:bg-[#F5F5F7] rounded-2xl transition-colors cursor-pointer group">
                                                <div className="w-14 h-14 bg-[#F5F5F7] group-hover:bg-white rounded-xl flex flex-col items-center justify-center mr-4 border border-[#D2D2D7]/30">
                                                    <span className="text-xs font-bold text-[#FF3B30] uppercase">Oct</span>
                                                    <span className="text-xl font-bold text-[#1D1D1F]">24</span>
                                                </div>
                                                <div className="flex-1">
                                                    <h4 className="font-semibold text-[#1D1D1F] text-lg">General Checkup</h4>
                                                    <p className="text-[#86868B]">10:00 AM • John Doe</p>
                                                </div>
                                                <button className="bg-[#F5F5F7] group-hover:bg-[#0071E3] group-hover:text-white text-[#1D1D1F] px-4 py-2 rounded-xl font-medium transition-all">
                                                    View
                                                </button>
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                <div className="bg-[#1D1D1F] rounded-[2rem] p-8 text-white relative overflow-hidden">
                                    <div className="absolute top-0 right-0 w-64 h-64 bg-[#0071E3] rounded-full blur-[80px] opacity-20 -mr-16 -mt-16"></div>
                                    <h2 className="text-2xl font-bold mb-4 relative z-10">AI Insights</h2>
                                    <p className="text-[#86868B] mb-8 relative z-10">You have 3 patients requiring attention based on recent lab results.</p>
                                    <button className="w-full bg-white/10 hover:bg-white/20 backdrop-blur-md text-white border border-white/20 py-3 rounded-xl font-medium transition-all relative z-10">
                                        View Analysis
                                    </button>
                                </div>
                            </div>
                        </div>
                    )}

                    {activeTab === 'patients' && (
                        <div className="bg-white rounded-[2rem] shadow-sm border border-[#D2D2D7]/30 overflow-hidden">
                            <table className="w-full">
                                <thead className="bg-[#F5F5F7] border-b border-[#D2D2D7]/50 top-0 sticky z-10">
                                    <tr>
                                        <th className="px-8 py-4 text-left text-xs font-semibold text-[#86868B] uppercase tracking-wider">Patient</th>
                                        <th className="px-6 py-4 text-left text-xs font-semibold text-[#86868B] uppercase tracking-wider">Age</th>
                                        <th className="px-6 py-4 text-left text-xs font-semibold text-[#86868B] uppercase tracking-wider">Condition</th>
                                        <th className="px-6 py-4 text-left text-xs font-semibold text-[#86868B] uppercase tracking-wider">Status</th>
                                        <th className="px-6 py-4 text-left text-xs font-semibold text-[#86868B] uppercase tracking-wider">Last Visit</th>
                                        <th className="px-8 py-4 text-right text-xs font-semibold text-[#86868B] uppercase tracking-wider">Action</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-[#F5F5F7]">
                                    {PATIENTS.map((patient) => (
                                        <tr key={patient.id} className="hover:bg-[#F5F5F7]/50 transition-colors">
                                            <td className="px-8 py-5">
                                                <div className="flex items-center">
                                                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center text-sm font-bold text-[#424245] mr-4">
                                                        {patient.avatar}
                                                    </div>
                                                    <div className="font-semibold text-[#1D1D1F]">{patient.name}</div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-5 text-[#424245]">{patient.age}</td>
                                            <td className="px-6 py-5 text-[#424245]">{patient.condition}</td>
                                            <td className="px-6 py-5">
                                                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${patient.status === 'Critical' ? 'bg-red-100 text-red-800' :
                                                        patient.status === 'Review' ? 'bg-yellow-100 text-yellow-800' :
                                                            'bg-green-100 text-green-800'
                                                    }`}>
                                                    {patient.status}
                                                </span>
                                            </td>
                                            <td className="px-6 py-5 text-[#86868B]">{patient.lastVisit}</td>
                                            <td className="px-8 py-5 text-right">
                                                <button className="text-[#0071E3] hover:text-[#0077ED] font-medium text-sm">View Details</button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </motion.div>
            </main>
        </div>
    );
}
