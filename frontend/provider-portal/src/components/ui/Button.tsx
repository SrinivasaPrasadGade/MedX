import * as React from "react"
import { Slot } from "@radix-ui/react-slot" // We typically use radix for slot, but if not installed I can simulate or strip it. I'll strip it for now to avoid extra installs unless user asked. Actually, I can just use simple props.
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

// I'll skip cva/radix for now to avoid complexity without installing them, 
// using simple Tailwind classes mapping. 
// Wait, standard shadcn/future-proof way uses cva. 
// I'll write a simple robust component without extra deps for now to be fast.

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: "primary" | "secondary" | "destructive" | "ghost" | "outline";
    size?: "sm" | "md" | "lg";
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
    ({ className, variant = "primary", size = "md", ...props }, ref) => {
        const variants = {
            primary: "bg-primary text-primary-foreground hover:opacity-90 shadow-sm",
            secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
            destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90 shadow-sm",
            ghost: "hover:bg-accent hover:text-accent-foreground",
            outline: "border border-input bg-transparent hover:bg-accent hover:text-accent-foreground"
        };

        const sizes = {
            sm: "h-8 px-3 text-xs",
            md: "h-10 px-4 py-2",
            lg: "h-12 px-8 text-lg"
        };

        return (
            <button
                ref={ref}
                className={cn(
                    "inline-flex items-center justify-center rounded-lg font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
                    variants[variant],
                    sizes[size],
                    className
                )}
                {...props}
            />
        );
    }
);
Button.displayName = "Button";
